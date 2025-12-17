#if UNITY_EDITOR
using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class MazeDecoratorTab
{
    //Group
    public Transform mazeParent;
    public List<GameObject> decorationPrefabs = new List<GameObject>();
    public float decorationDensity = 0.3f;
    public float OffsetMin = 0.5f;
    public float OffsetMax = 1.5f;
    public float ScaleMin = 1f;
    public float ScaleMax = 2f;
    MazeTab mazeTab;//把這個傳進來

    public void DrawGUI()
    {
        GUILayout.Label("Decoration Settings", EditorStyles.boldLabel);
        mazeParent = (Transform)EditorGUILayout.ObjectField("Group", mazeParent, typeof(Transform), true);

        EditorGUILayout.LabelField("Decoration Prefabs (List)");
        int removeIndex = -1;
        for (int i = 0; i < decorationPrefabs.Count; i++)
        {
            GUILayout.BeginHorizontal();
            decorationPrefabs[i] = (GameObject)EditorGUILayout.ObjectField(
                decorationPrefabs[i],
                typeof(GameObject),
                false
            );

            if (GUILayout.Button("X", GUILayout.Width(20)))
                removeIndex = i;

            GUILayout.EndHorizontal();
        }

        if (removeIndex >= 0)
            decorationPrefabs.RemoveAt(removeIndex);

        if (GUILayout.Button("Add Prefab"))
        {
            decorationPrefabs.Add(null);
        }

        decorationDensity = EditorGUILayout.Slider("Density", decorationDensity, 0f, 1f);
        EditorGUILayout.LabelField("Decoration Offset");
        OffsetMin = EditorGUILayout.FloatField("Min", OffsetMin);
        OffsetMax = EditorGUILayout.FloatField("Max", OffsetMax);
        EditorGUILayout.LabelField("Scale Range");
        ScaleMin = EditorGUILayout.FloatField("Min", ScaleMin);
        ScaleMax = EditorGUILayout.FloatField("Max", ScaleMax);

        GUILayout.Space(4);
        GUILayout.BeginHorizontal();
        if (GUILayout.Button("Generate Decorations"))
        {
            MazeDecorator.Decorate(
                mazeParent,
                decorationPrefabs,
                decorationDensity,
                OffsetMin,
                OffsetMax,
                ScaleMin,
                ScaleMax
            );
        }
        if (GUILayout.Button("Clear Decorations"))
        {
            MazeDecorator.ClearDecorations();
        }
        GUILayout.EndHorizontal();
    }

}
#endif