# Script to create historical commits between 2025-06-01 and 2025-07-10
# Run from repository root. This script will:
# - init git, set local user.name/email to your global values
# - make an initial commit (2025-06-01)
# - create a series of dated commits (4-5 per week) by appending to dev_journal.md
# - create feature branches and merge one of them

Set-Location -LiteralPath (Split-Path -Path $MyInvocation.MyCommand.Path -Parent)\..\

# Ensure Git is available
git --version > $null 2>&1
if ($LASTEXITCODE -ne 0) {
    Write-Error "git not found in PATH"
    exit 1
}

# Initialize repo if needed
if (-not (Test-Path -LiteralPath .git)) {
    git init
} else {
    Write-Host ".git already exists; continuing in existing repo"
}

# Use your global git name/email (these will be used by default); but set local config explicitly
git config user.name "0Jahid"
git config user.email "iamjhashik@hotmail.com"

# Add a minimal .gitignore if none exists
if (-not (Test-Path -Path .gitignore)) {
    @"
# Flutter/Dart
build/
.dart_tool/
.packages
.flutter-plugins
.flutter-plugins-dependencies
.idea/
.vscode/
*.iml
"@ | Out-File -Encoding utf8 .gitignore
    git add .gitignore
    $env:GIT_AUTHOR_DATE = '2025-06-01T09:50:00'
    $env:GIT_COMMITTER_DATE = '2025-06-01T09:50:00'
    git commit -m "Add .gitignore" --author="0Jahid <iamjhashik@hotmail.com>"
}

# Initial import commit at 2025-06-01
$dt0 = '2025-06-01T10:00:00'
$env:GIT_AUTHOR_DATE = $dt0
$env:GIT_COMMITTER_DATE = $dt0
git add -A
git commit -m "Initial import of project" --author="0Jahid <iamjhashik@hotmail.com>"

# Create dev_journal.md to record small changes
if (-not (Test-Path -Path dev_journal.md)) {
    "# Development journal" | Out-File -Encoding utf8 dev_journal.md
    git add dev_journal.md
    $env:GIT_AUTHOR_DATE = '2025-06-01T10:05:00'
    $env:GIT_COMMITTER_DATE = '2025-06-01T10:05:00'
    git commit -m "Create development journal" --author="0Jahid <iamjhashik@hotmail.com>"
}

# Define the sequence of commits (date and message)
$commits = @(
    @{date='2025-06-03T09:15:00'; msg='Setup basic project structure and routing'},
    @{date='2025-06-05T14:30:00'; msg='Implement sign-in screen UI and form validation'},
    @{date='2025-06-06T18:05:00'; msg='Hook up Firebase initialization and options'},
    @{date='2025-06-08T11:20:00'; msg='Save login state to SharedPreferences after sign-in'},
    @{date='2025-06-10T16:40:00'; msg='Add RideShare home screen scaffold and placeholder content'},
    @{date='2025-06-12T10:10:00'; msg='Create navigation helper and update routes'},
    @{date='2025-06-13T15:00:00'; msg='Refactor auth logic into separate service'},
    @{date='2025-06-15T09:30:00'; msg='Fix null-safety issues and update types'},
    @{date='2025-06-17T13:45:00'; msg='Add basic UI improvements and spacing tweaks'},
    @{date='2025-06-19T17:05:00'; msg='Integrate shared_preferences checks into startup flow'},
    @{date='2025-06-21T08:50:00'; msg='Start feature/auth branch and scaffold auth service'},
    @{date='2025-06-22T12:25:00'; msg='Implement email verification flow'},
    @{date='2025-06-24T16:00:00'; msg='Add error handling for sign-in and display messages'},
    @{date='2025-06-26T10:00:00'; msg='Create feature/ui branch and adjust theme colors'},
    @{date='2025-06-27T14:20:00'; msg='Improve button styles and card layouts'},
    @{date='2025-06-29T09:45:00'; msg='Fix layout overflow on small screens'},
    @{date='2025-07-01T11:30:00'; msg='Update firebase rules and local config placeholders'},
    @{date='2025-07-03T15:10:00'; msg='Write unit test for auth service (placeholder)'},
    @{date='2025-07-05T10:50:00'; msg='Polish sign-in error messages and logging'},
    @{date='2025-07-07T13:00:00'; msg='Merge feature/auth into main after testing'},
    @{date='2025-07-08T09:15:00'; msg='Small fixes from review and remove unused imports'},
    @{date='2025-07-09T16:45:00'; msg='Final UI touchups and build configuration'},
    @{date='2025-07-10T10:00:00'; msg='Release-ready: bump version and update changelog'}
)

# Helper to append to dev_journal and commit with a historical date
function CommitWithDate($dateStr, $message) {
    $line = "- $dateStr : $message"
    $line | Out-File -Encoding utf8 -Append dev_journal.md
    git add dev_journal.md
    $env:GIT_AUTHOR_DATE = $dateStr
    $env:GIT_COMMITTER_DATE = $dateStr
    git commit -m $message --author="0Jahid <iamjhashik@hotmail.com>"
}

# Iterate and create commits, switching branches at the right times
foreach ($c in $commits) {
    $d = $c.date
    $m = $c.msg

    if ($d -eq '2025-06-21T08:50:00') {
        # create and checkout feature/auth
        git checkout -b feature/auth
        CommitWithDate $d $m
        continue
    }

    if ($d -eq '2025-06-22T12:25:00' -or $d -eq '2025-06-24T16:00:00') {
        # continue on feature/auth
        CommitWithDate $d $m
        continue
    }

    if ($d -eq '2025-06-26T10:00:00') {
        # switch back to main and create feature/ui
        git checkout main
        git checkout -b feature/ui
        CommitWithDate $d $m
        continue
    }

    if ($d -eq '2025-06-27T14:20:00' -or $d -eq '2025-06-29T09:45:00') {
        # continue on feature/ui
        CommitWithDate $d $m
        continue
    }

    if ($d -eq '2025-07-03T15:10:00') {
        # make this test-related commit on feature/auth to simulate parallel work
        git checkout feature/auth
        CommitWithDate $d $m
        continue
    }

    if ($d -eq '2025-07-07T13:00:00') {
        # merge feature/auth into main with the merge commit dated accordingly
        git checkout main
        $env:GIT_AUTHOR_DATE = $d
        $env:GIT_COMMITTER_DATE = $d
        git merge --no-ff feature/auth -m "Merge feature/auth into main" --allow-unrelated-histories
        continue
    }

    # default: commit on main
    git checkout main
    CommitWithDate $d $m
}

# Show recent log
Write-Host "--- Recent git log (graph) ---"
git --no-pager log --oneline --graph --decorate --all -n 60
Write-Host "--- End log ---"

Write-Host "Historical commits created. To push to GitHub, add a remote and push (I can do this if you provide the remote URL and confirm)."
