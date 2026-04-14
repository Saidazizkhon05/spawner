import 'dart:io';

import 'package:spawner/models/project_config.dart';

class LauncherService {
  Future<void> launchProject(ProjectConfig project) async {
    final futures = <Future<void>>[];

    if (project.openVscode) {
      futures.add(_launchVscode(project));
    }

    if (project.openIterm) {
      futures.add(_launchIterm(project.projectPath));
    }

    if (project.openClaude) {
      futures.add(_launchClaude(project.projectPath));
    }

    for (final app in project.additionalApps) {
      futures.add(_launchApp(app));
    }

    await Future.wait(futures);
  }

  Future<void> _launchVscode(ProjectConfig project) async {
    final args = <String>[project.projectPath];
    for (final file in project.vscodeFiles) {
      args.add(file);
    }
    await Process.run('code', args);
  }

  Future<void> _launchIterm(String path) async {
    final script =
        '''
      tell application "iTerm"
        activate
        create window with default profile
        tell current session of current window
          write text "cd ${_escapeAppleScript(path)}"
        end tell
      end tell
    ''';
    await Process.run('osascript', ['-e', script]);
  }

  Future<void> _launchClaude(String path) async {
    final script =
        '''
      tell application "iTerm"
        activate
        create window with default profile
        tell current session of current window
          write text "cd ${_escapeAppleScript(path)} && claude"
        end tell
      end tell
    ''';
    await Process.run('osascript', ['-e', script]);
  }

  Future<void> _launchApp(String appName) async {
    await Process.run('open', ['-a', appName]);
  }

  String _escapeAppleScript(String value) {
    return value.replaceAll('\\', '\\\\').replaceAll('"', '\\"');
  }
}
