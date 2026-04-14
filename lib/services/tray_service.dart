import 'dart:io' show exit;

import 'package:flutter/material.dart';
import 'package:system_tray/system_tray.dart';

import 'package:spawner/models/project_config.dart';
import 'package:spawner/services/launcher_service.dart';

class TrayService {
  final SystemTray _systemTray = SystemTray();
  final LauncherService _launcherService = LauncherService();
  VoidCallback? onShowWindow;

  Future<void> init() async {
    await _systemTray.initSystemTray(
      title: '',
      iconPath: 'assets/app_icon.png',
      toolTip: 'Spawner',
    );

    _systemTray.registerSystemTrayEventHandler((eventName) {
      if (eventName == kSystemTrayEventClick || eventName == kSystemTrayEventRightClick) {
        _systemTray.popUpContextMenu();
      }
    });
  }

  Future<void> updateMenu(List<ProjectConfig> projects) async {
    final menuItems = <MenuItemBase>[];

    if (projects.isEmpty) {
      menuItems.add(MenuItemLabel(label: 'No projects configured', enabled: false));
    } else {
      for (final project in projects) {
        menuItems.add(
          MenuItemLabel(
            label: project.name,
            onClicked: (_) => _launcherService.launchProject(project),
          ),
        );
      }
    }

    menuItems.add(MenuSeparator());
    menuItems.add(MenuItemLabel(label: 'Open Spawner', onClicked: (_) => onShowWindow?.call()));
    menuItems.add(MenuItemLabel(label: 'Quit', onClicked: (_) => _quit()));

    final menu = Menu();
    await menu.buildFrom(menuItems);
    await _systemTray.setContextMenu(menu);
  }

  void _quit() {
    _systemTray.destroy();
    exit(0);
  }
}
