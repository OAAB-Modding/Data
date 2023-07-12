import os
from github import Github, Auth, Commit, Repository


def collect_paths(repo: Repository, commit: Commit) -> dict[str, list[str]]:
    root = repo.get_git_tree(commit.sha, recursive=True)

    results: dict[str, list[str]] = {}

    # Group paths by lowercase form
    for element in root.tree:
        key = element.path.lower()
        group = results.setdefault(key, [])
        group.append(element.path)

    return results


def parents_recursive(child: Commit):
    for commit in child.parents:
        yield commit
        yield from commit.parents


def get_last_successful_parent_commit(child: Commit) -> Commit:
    for commit in parents_recursive(child):
        checks = commit.get_check_runs()
        if all(check.conclusion == "success" for check in checks):
            print(f'Found successful parent commit: {commit.sha}')
            return commit

        # This is the commit where we first introduced this script.
        # This part of the code can be removed after the first run.
        if commit.sha == "6f019f37f46f8d46d61506e4f61958035ab78dc4":
            return commit

    print("Warning: Could not find a successful parent commit")
    return child.parents[0]


if __name__ == "__main__":
    print("Authenticating...")

    token = Auth.Token(os.environ["GITHUB_TOKEN"])
    gh = Github(auth=token)
    repo = gh.get_repo(os.environ["GITHUB_REPOSITORY"])

    print("Retrieving commits...")

    latest_commit = repo.get_commit(os.environ["GITHUB_SHA"])
    parent_commit = get_last_successful_parent_commit(latest_commit)

    latest_paths = collect_paths(repo, latest_commit)
    parent_paths = collect_paths(repo, parent_commit)

    print("Checking for errors...")

    errors_found = False

    # Error if the same path appeared more than once with different casing.
    for group in latest_paths.values():
        if len(group) > 1:
            print(f'Duplicated path with different casing: {group}')
            errors_found = True

    # Error if the same path appeared in both commits with different casing.
    for key, latest_path in latest_paths.items():
        if parent_path := parent_paths.get(key):
            if latest_path != parent_path:
                print(f'Path casing not match parent commit: "{latest_path}" vs "{parent_path}"')
                errors_found = True

    print(f"Errors found: {errors_found}\n")

    if errors_found:
        raise Exception("Validation Failed")
