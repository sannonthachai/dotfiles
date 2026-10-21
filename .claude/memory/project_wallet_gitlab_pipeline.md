---
name: project-wallet-gitlab-pipeline
description: Divine Wallet self-hosted GitLab — how to inspect it and the CI pipeline optimization done 2026-06-30
metadata: 
  node_type: memory
  type: project
  originSessionId: 7e6f75b5-0a6c-4638-b00d-141c0a2780a2
---

Divine Wallet self-hosted GitLab (`dv-srv-gitlab`, gitlab.dwl.internal), reached via `ssh wallet-share-gitlab`. GitLab CE + gitlab-runner both run in Docker on that host (`sudo docker exec gitlab ...`).

**Inspecting repos (no git creds on the host):** repos are `@hashed`, so resolve a path with
`sudo docker exec gitlab gitlab-rails runner 'puts Project.find_by_full_path("group/repo").disk_path'`
then `cd /var/opt/gitlab/git-data/repositories/@hashed/<disk_path>.git` and `git show <branch>:<file>` (run `git config --global --add safe.directory <dir>` first). CI lint via `Gitlab::Ci::Lint.new(project:, current_user:, sha:).validate(content, dry_run: true, ref: "dev")`.

**Pipeline layout:** `tsb-wallet/*` apps are Quarkus; their `.gitlab-ci.yml` just `include`s the shared template `infrastructure/cicd → java/gitlab-ci.yml`. Base CI image `swr.ap-southeast-2.myhuaweicloud.com/wallet/java` is built by `docker-template/java` (Kaniko). Runner `instance-runner-01` (tag `java`, privileged, docker.sock mounted) uses that image; a stale `docker-runner` (id 37, alpine) is invalid server-side — ignore it.

**Optimization done 2026-06-30:** root cause was the template caching `~/.m2` (= /root/.m2, outside `$CI_PROJECT_DIR`) so the cache stored nothing → every job re-downloaded ~2600 deps; plus the project was compiled 4× (prepare/build-service/build-docker/build-sonar) and runner ran `concurrent=1` (everything serialized).

Fixes applied: build once in `build-service`, pass `target/` artifact to docker/sonar via `needs:` (dropped the `prepare` stage); BuildKit on with `--cache-from :latest`; runner `concurrent` 1→2.

Maven cache — IMPORTANT: GitLab's archive `cache:` does NOT work on this single-host docker executor (local cache is per-concurrency-slot → "Failed to extract cache" once concurrent>1). The working fix is a shared Docker named volume mounted at /root/.m2 on the `java` runner: `volumes=[...,"m2cache:/root/.m2"]`. Do NOT redirect maven.repo.local to $CI_PROJECT_DIR (that overrides the mount). Sonar must run ONLINE (no `-o`) so the sonar-maven-plugin can resolve; everything else comes from the shared volume. The m2cache volume is shared across ALL tsb-wallet repos — verified core-api ran with downloads=0 after support-api warmed it.

Results (support-api warm run): build-service 185→25s, build-docker-dev 336→8s, build-sonar 286→41s. All 8 active tsb-wallet repos just `include` the template so they inherit it automatically (demo-backend/demo-frontend have no pipeline). Leftover: `docker-template/java` 166MB m2.tar.gz removed from HEAD but still in git history.
