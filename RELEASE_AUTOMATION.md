# Automated Release Guide

## Overview
This repository now includes GitHub Actions automation for building and releasing APK files. You no longer need to manually build and upload APKs!

## How It Works

### Automatic Release Process
1. **Tag your commit** with a version number (e.g., `v1.2.0`)
2. **Push the tag** to GitHub
3. **GitHub Actions automatically**:
   - Builds the release APK
   - Creates a GitHub Release
   - Uploads the APK to the release
   - Uses your release notes file

### Step-by-Step Instructions

#### 1. Prepare Your Release
Make sure all your changes are committed:
```bash
git add .
git commit -m "Release v1.2.0: Add reading progress bar and image caching"
```

#### 2. Create and Push a Version Tag
```bash
# Create a tag (replace v1.2.0 with your version)
git tag v1.2.0

# Push the tag to GitHub
git push origin v1.2.0
```

#### 3. Wait for Automation
- Go to your repository's "Actions" tab on GitHub
- Watch the build process (takes ~5-10 minutes)
- Once complete, check the "Releases" page

#### 4. Verify the Release
- The APK will be automatically uploaded
- Release notes from `RELEASE_NOTES_v1.2.0.md` will be included
- Download link will be available immediately

## Release Notes Format

For each version, create a file named `RELEASE_NOTES_v{VERSION}.md` in the root directory:
- Example: `RELEASE_NOTES_v1.2.0.md`
- This file will be used as the release description
- Include what's new, bug fixes, and breaking changes

## Troubleshooting

### Build Fails
- Check the Actions tab for error logs
- Ensure `pubspec.yaml` version matches your tag
- Verify all dependencies are correctly specified

### Release Not Created
- Ensure you pushed the **tag**, not just the commit
- Tag must follow format: `v*.*.*` (e.g., `v1.2.0`)
- Check GitHub Actions permissions in repository settings

### Manual Override
If you need to build manually:
```bash
flutter build apk --release
```
The APK will be in: `build/app/outputs/flutter-apk/app-release.apk`

## Version Numbering

Follow semantic versioning:
- **Major** (v2.0.0): Breaking changes
- **Minor** (v1.2.0): New features, backward compatible
- **Patch** (v1.2.1): Bug fixes only

## Best Practices

1. **Update version in `pubspec.yaml`** before tagging
2. **Create release notes** before pushing tag
3. **Test thoroughly** before creating a release tag
4. **Use descriptive commit messages** for the release commit

## Example Workflow

```bash
# 1. Update version in pubspec.yaml
# version: 1.2.0+2

# 2. Create release notes
# Create RELEASE_NOTES_v1.2.0.md

# 3. Commit changes
git add .
git commit -m "Release v1.2.0: Performance improvements and UX enhancements"

# 4. Create and push tag
git tag v1.2.0
git push origin main
git push origin v1.2.0

# 5. Wait for GitHub Actions to complete
# 6. Check Releases page for your new release!
```

## Need Help?

If automation fails or you need to make changes:
1. Delete the tag locally: `git tag -d v1.2.0`
2. Delete the tag remotely: `git push origin :refs/tags/v1.2.0`
3. Fix the issue
4. Create the tag again

---

**Happy Releasing! 🚀**
