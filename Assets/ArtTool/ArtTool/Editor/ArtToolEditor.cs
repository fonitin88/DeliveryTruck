using UnityEditor;
using UnityEngine;

public class ArtToolEditor : EditorWindow
{
    #region [數據成員]
    string[] categoryNames = { "測試專用", "Spawn", "Group", "Replace", "Pratice", "SpawnRotate", "TileSpawn" }; //Selection Grid是一個數組類型所以使用string[]
    int selectedID;//初始直是0
    const string selectedIDKey = "selectedID";

    //從外部調用功能1（宣告Declaration）
    PracticeEditor practice;
    EnvTools envtools;
    test Test;
    ReplaceEditor replace;
    GroupEditor groupEditor;
    SpawnRotateEditor spawnRotate;
    TileSpawn tileSpawn;

    #endregion

    [MenuItem("Tools/ArtTool")]//開啟視窗
    public static void Open()
    {
        var window = EditorWindow.GetWindow(typeof(ArtToolEditor), false, "美術", false);
        window.Show();
    }

    void OnEnable()//初始化
    {
        //從外部調用功能2（實例化Instantiation）
        practice = new PracticeEditor();
        envtools = new EnvTools();
        Test = new test();
        replace = new ReplaceEditor();
        groupEditor = new GroupEditor();
        spawnRotate = new SpawnRotateEditor();
        tileSpawn = new TileSpawn();

        //讀取之前存的API,帶入上次選的按鈕頁面
        selectedID = EditorPrefs.GetInt(selectedIDKey);
    }
    void OnDisable()//關掉前才會記錄,只讀一次
    {
        //存取API 記憶上次選的按鈕頁面
        EditorPrefs.SetInt(selectedIDKey, selectedID);
    }
    void OnGUI()
    {

        EditorGUILayout.BeginHorizontal();
        {
            //加入效果框
            EditorGUILayout.BeginVertical(EditorStyles.helpBox, GUILayout.Width(70), GUILayout.ExpandHeight(true));
            //左側欄選單按鈕
            selectedID = GUILayout.SelectionGrid(selectedID, categoryNames, 1);
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginVertical();
            //從外部調用功能3（使用）
            switch (selectedID)
            {
                case 0:
                    Test.Draw();
                    break;
                case 1:
                    envtools.Draw();
                    break;
                case 2:
                    groupEditor.Draw();
                    break;
                case 3:
                    replace.Draw();
                    break;
                case 4:
                    practice.Draw();
                    break;
                case 5:
                    spawnRotate.Draw();
                    break;
                    ;
                case 6:
                    tileSpawn.Draw();
                    break;
                    ;
            }
            EditorGUILayout.EndVertical();

        }
        EditorGUILayout.EndHorizontal();

        if (GUILayout.Button("重置設定"))
        {
            EditorPrefs.DeleteAll();
        }

        GUILayout.Label("Update:2025.02", EditorStyles.centeredGreyMiniLabel);
    }
}

