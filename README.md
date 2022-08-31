# ys_play

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter
[plug-in package](https://flutter.dev/developing-packages/),
a specialized package that includes platform-specific implementation code for
Android and/or iOS.

For help getting started with Flutter development, view the
[online documentation](https://flutter.dev/docs), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

android端集成步骤：
1.project下的MainActivity中注册插件：

@Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterEngine.getPlatformViewsController().getRegistry().registerViewFactory("com.example.ys_play",
                new YsPlayViewFactory(flutterEngine.getDartExecutor().getBinaryMessenger(),getApplication()));
    }

