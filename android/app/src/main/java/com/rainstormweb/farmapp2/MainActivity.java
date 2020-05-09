package com.rainstormweb.farmapp2;

import androidx.appcompat.app.AppCompatActivity;

import android.annotation.TargetApi;
import android.app.Activity;
import android.content.ClipData;
import android.content.Intent;
import android.net.http.SslError;
import android.os.Build;
import android.os.Bundle;
import android.os.Environment;
import android.os.Parcelable;
import android.provider.MediaStore;
import android.webkit.PermissionRequest;
import android.webkit.SslErrorHandler;
import android.webkit.WebView;
import android.webkit.WebViewClient;
import android.webkit.WebChromeClient;
import android.webkit.WebSettings;
import android.webkit.ValueCallback;
import android.net.Uri;
import android.util.Log;

import java.io.File;

public class MainActivity extends AppCompatActivity {

    private WebView myView;
    private static final int FILECHOOSER_RESULTCODE   = 2888;
    private Uri mCapturedImageURI = null;
    private ValueCallback<Uri[]> mUploadMessageL;
    private ValueCallback<Uri> mUploadMessage;

    @Override
    protected void onCreate(Bundle savedInstanceState) {
        super.onCreate(savedInstanceState);
        try {
            this.getSupportActionBar().hide();
        }
        catch (NullPointerException e){}
        setContentView(R.layout.activity_main);
        myView = findViewById( R.id.simpleWebView );
        myView.setWebViewClient(new MyWebViewClient());
        myView.setWebChromeClient(new MyWebChromeClient());
        myView.getSettings().setJavaScriptEnabled(true);
        myView.getSettings().setDomStorageEnabled(true);
        myView.getSettings().setPluginState(WebSettings.PluginState.ON);
        if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP)
            myView.getSettings().setMediaPlaybackRequiresUserGesture(false);
        //myView.loadUrl("file:///android_asset/index.html");
        myView.loadUrl("https://192.168.0.2:9000");

    }

    @Override
    protected void onPostCreate(Bundle savedInstanceState) {
        super.onPostCreate(savedInstanceState);

    }

    private class MyWebViewClient extends WebViewClient {
        @Override
        public boolean shouldOverrideUrlLoading(WebView view, String url) {
            view.loadUrl(url);
            return true;
        }
        @Override
        public void onReceivedSslError(WebView view, SslErrorHandler handler, SslError error){
            handler.proceed();
        }
    }

    private class MyWebChromeClient extends WebChromeClient {
        public void openFileChooser(ValueCallback<Uri> valueCallback, String acceptType, String capture) {
            mUploadMessage = valueCallback;
            openImageChooser();
        }
        @Override
        public boolean onShowFileChooser(WebView webView, ValueCallback<Uri[]> filePathCallback, FileChooserParams fileChooserParams) {
            mUploadMessageL = filePathCallback;
            openImageChooser();
            return true;
        }
        @Override
        public void onPermissionRequest(final PermissionRequest request){
            if(Build.VERSION.SDK_INT >= Build.VERSION_CODES.LOLLIPOP) {
                request.grant(request.getResources());
            }
        }
        private void openImageChooser() {
            File imageStorageDir = new File(
                    Environment.getExternalStoragePublicDirectory(Environment.DIRECTORY_PICTURES)
                    , "FarmTestFolder"
            );
            if(!imageStorageDir.exists()) {
                imageStorageDir.mkdirs();
            }
            File file = new File(imageStorageDir + File.separator + "IMG_" + System.currentTimeMillis() + ".jpg");
            mCapturedImageURI = Uri.fromFile(file);
            final Intent captureIntent = new Intent(MediaStore.ACTION_IMAGE_CAPTURE);
            captureIntent.putExtra(MediaStore.EXTRA_OUTPUT, mCapturedImageURI);
            Intent i = new Intent(Intent.ACTION_GET_CONTENT);
            i.addCategory(Intent.CATEGORY_OPENABLE);
            i.setType("image/*");
            Intent chooserIntent = Intent.createChooser(i, "Image Chooser");
            chooserIntent.putExtra(Intent.EXTRA_INITIAL_INTENTS, new Parcelable[] {captureIntent});
            startActivityForResult(chooserIntent, FILECHOOSER_RESULTCODE);
        }
    }
    @Override
    protected void onActivityResult(int requestCode, int resultCode, Intent data) {
        super.onActivityResult(requestCode, resultCode, data);
        if (requestCode == FILECHOOSER_RESULTCODE) {
            if (null == mUploadMessageL) return;
            Uri result = data == null || resultCode != RESULT_OK ? null : data.getData();
            if(mUploadMessageL !=null) {
                onActivityResultL(requestCode, resultCode, data);
            } else if (mUploadMessage != null) {
                mUploadMessage.onReceiveValue(result);
                mUploadMessage = null;
            }
        }
    }
    @TargetApi(Build.VERSION_CODES.LOLLIPOP)
    protected void onActivityResultL(int requestCode, int resultCode, Intent intent) {
        super.onActivityResult(requestCode,resultCode,intent);
        if(requestCode==FILECHOOSER_RESULTCODE)
        {
            Uri[] results = null;
            if(resultCode == Activity.RESULT_OK) {
                if(intent != null) {
                    String dataString = intent.getDataString();
                    ClipData clipData = intent.getClipData();
                    if (clipData != null) {
                        results = new Uri[clipData.getItemCount()];
                        for (int i = 0; i < clipData.getItemCount(); i++) {
                            ClipData.Item item = clipData.getItemAt(i);
                            results[i] = item.getUri();
                        }
                    }
                    if(dataString != null)
                        results = new Uri[]{Uri.parse(dataString)};
                }
            }
            mUploadMessageL.onReceiveValue(results);
            mUploadMessageL = null;
        }
    }
    @Override
    public void onBackPressed() {
        if(myView.canGoBack()){
            myView.goBack();
        } else {
            super.onBackPressed();
        }
    }
}
