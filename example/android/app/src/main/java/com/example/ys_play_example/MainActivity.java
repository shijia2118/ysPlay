package com.example.ys_play_example;

import androidx.annotation.NonNull;

import com.example.ys_play.YsPlayViewFactory;

import io.flutter.embedding.android.FlutterActivity;
import io.flutter.embedding.engine.FlutterEngine;

public class MainActivity extends FlutterActivity {

    @Override
    public void configureFlutterEngine(@NonNull FlutterEngine flutterEngine) {
        super.configureFlutterEngine(flutterEngine);
        flutterEngine.getPlatformViewsController().getRegistry().registerViewFactory("com.example.ys_play",
                new YsPlayViewFactory(flutterEngine.getDartExecutor().getBinaryMessenger(),getApplication()));
    }
}
