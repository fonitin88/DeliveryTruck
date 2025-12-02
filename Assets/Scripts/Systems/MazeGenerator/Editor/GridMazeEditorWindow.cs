#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GridMazeEditorWindow : EditorWindow
{

    private enum Tab { Maze, Decorate }
    private Tab currentTab = Tab.Maze;

    MazeTab mazeTab;
    MazeDecoratorTab mazeDecoratorTab;

    [MenuItem("Tools/Maze Generator")]
    public static void ShowWindow()
    {
        GetWindow<GridMazeEditorWindow>("Maze Generator");
    }

    void OnEnable()
    {
        mazeTab = new MazeTab();
        mazeDecoratorTab = new MazeDecoratorTab();
    }

    private void OnGUI()
    {
        currentTab = (Tab)GUILayout.Toolbar(
            (int)currentTab,
            new[] { "Maze", "Decoration" }
        );

        GUILayout.Space(8);

        switch (currentTab)
        {
            case Tab.Maze:
                mazeTab.DrawGUI();        // 👉 只呼叫，不做邏輯
                break;
            case Tab.Decorate:
                mazeDecoratorTab.DrawGUI();
                break;

        }
    }
}
#endif
