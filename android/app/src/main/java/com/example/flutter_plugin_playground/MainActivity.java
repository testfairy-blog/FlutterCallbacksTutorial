package com.example.flutter_plugin_playground;

import android.os.Bundle;
import android.os.Handler;
import android.util.Log;

import java.lang.reflect.Method;
import java.util.HashMap;
import java.util.Map;

import io.flutter.app.FlutterActivity;
import io.flutter.plugin.common.MethodCall;
import io.flutter.plugin.common.MethodChannel;
import io.flutter.plugins.GeneratedPluginRegistrant;

public class MainActivity extends FlutterActivity {
  private MethodChannel channel;

  @Override
  protected void onCreate(Bundle savedInstanceState) {
    super.onCreate(savedInstanceState);
    GeneratedPluginRegistrant.registerWith(this);

    // Prepare channel
    channel = new MethodChannel(getFlutterView(), "callbacks");
    channel.setMethodCallHandler(new MethodChannel.MethodCallHandler() {
      @Override
      public void onMethodCall(MethodCall methodCall, MethodChannel.Result result) {
        try {
          // Find a method with the same name in activity
          Method method = MainActivity.class.getDeclaredMethod(
                  methodCall.method,
                  Object.class,
                  MethodChannel.Result.class
          );

          // Call method if exists
          method.setAccessible(true);
          method.invoke(MainActivity.this, methodCall.arguments, result);
        } catch (Throwable t) {
          Log.e("Playground", "Exception during channel invoke", t);
          result.error("Exception during channel invoke", t.getMessage(), null);
        }
      }
    });
  }

  // Callbacks
  private Map<Integer, Runnable> callbackById = new HashMap<>();

  void startListening(Object args, MethodChannel.Result result) {
    // Get callback id
    int currentListenerId = (int) args;

    // Prepare a timer like self calling task
    final Handler handler = new Handler();
    callbackById.put(currentListenerId, new Runnable() {
      @Override
      public void run() {
        if (callbackById.containsKey(currentListenerId)) {
          Map<String, Object> args = new HashMap();

          args.put("id", currentListenerId);
          args.put("args", "Hello listener! " + (System.currentTimeMillis() / 1000));

          // Send some value to callback
          channel.invokeMethod("callListener", args);
        }

        handler.postDelayed(this, 1000);
      }
    });

    // Run task
    handler.postDelayed(callbackById.get(currentListenerId), 1000);

    // Return immediately
    result.success(null);
  }

  void cancelListening(Object args, MethodChannel.Result result) {
    // Get callback id
    int currentListenerId = (int) args;

    // Remove callback
    callbackById.remove(currentListenerId);

    // Do additional stuff if required to cancel the listener

    result.success(null);
  }
}
