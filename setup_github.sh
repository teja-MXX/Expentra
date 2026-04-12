#!/bin/bash
# ★ XPNS TRACKER — GitHub Push Script ★
# Run this once to push the project to GitHub and trigger the APK build.
#
# Usage:
#   chmod +x setup_github.sh
#   ./setup_github.sh https://github.com/YOUR_USERNAME/xpns-tracker.git

set -e

REPO_URL=${1:-""}

echo ""
echo "★━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━★"
echo "   XPNS TRACKER — GitHub Setup Script"
echo "★━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━★"
echo ""

# Check git is installed
if ! command -v git &> /dev/null; then
    echo "❌ git is not installed. Install from https://git-scm.com/"
    exit 1
fi

# Validate repo URL
if [ -z "$REPO_URL" ]; then
    echo "Usage: ./setup_github.sh https://github.com/YOUR_USERNAME/xpns-tracker.git"
    echo ""
    echo "Steps to create the repo first:"
    echo "  1. Go to https://github.com/new"
    echo "  2. Name it: xpns-tracker"
    echo "  3. Make it Public (so Actions run for free)"
    echo "  4. DO NOT add README / .gitignore (we have our own)"
    echo "  5. Copy the repo URL and run this script again"
    exit 1
fi

echo "✅ Repo URL: $REPO_URL"
echo ""

# Init git if not already
if [ ! -d ".git" ]; then
    echo "→ Initialising git repository..."
    git init
    git branch -M main
fi

# Set remote
if git remote get-url origin &> /dev/null; then
    echo "→ Updating remote origin to: $REPO_URL"
    git remote set-url origin "$REPO_URL"
else
    echo "→ Adding remote origin: $REPO_URL"
    git remote add origin "$REPO_URL"
fi

# Stage all files
echo "→ Staging all files..."
git add .

# Commit
echo "→ Committing..."
git commit -m "🚀 Initial commit: XPNS Tracker — Maximalist Flutter Expense App

- Dashboard with net worth, stats, insight card
- Add Transaction with numpad (<5 sec entry)
- Accounts: Bank / Credit Card / UPI / Cash
- Analytics: pie chart, bar chart, monthly comparison
- Budgets with 80%/100% alerts
- Transactions: searchable + swipe-to-delete
- Categories: CRUD with icon + color picker
- Riverpod state management
- Hive offline storage
- Credit card logic (due tracking, not deducting bank)
- GitHub Actions CI → auto-builds APK on every push

Designed in maximalist mixed-media art style 🎨" || echo "Nothing new to commit"

# Push
echo ""
echo "→ Pushing to GitHub..."
git push -u origin main

echo ""
echo "★━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━★"
echo "   ✅ PUSHED SUCCESSFULLY!"
echo "★━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━★"
echo ""
echo "🤖 GitHub Actions is now building your APK..."
echo ""
echo "To download your APK:"
echo "  1. Go to: ${REPO_URL%.git}/actions"
echo "  2. Click the latest 'Build XPNS APK' run"
echo "  3. Wait ~5-8 minutes for the build to finish"
echo "  4. Scroll to 'Artifacts' section at the bottom"
echo "  5. Download 'xpns-release-apk-*'"
echo "  6. Install on your Android phone!"
echo ""
echo "To trigger a build anytime:"
echo "  git add . && git commit -m 'update' && git push"
echo ""
echo "To create a tagged release (publishes APK automatically):"
echo "  git tag v1.0.0 && git push origin v1.0.0"
echo ""
