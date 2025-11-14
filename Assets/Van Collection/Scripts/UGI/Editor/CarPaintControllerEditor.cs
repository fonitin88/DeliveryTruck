using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(CarPaintController))]
public class CarPaintControllerEditor : Editor
{
    public override void OnInspectorGUI()
    {
        CarPaintController paint = (CarPaintController)target;

        // 顯示 Script 欄位
        GUI.enabled = false;
        EditorGUILayout.ObjectField("Script", MonoScript.FromMonoBehaviour(paint), typeof(CarPaintController), false);
        GUI.enabled = true;

        // 顯示 Renderer 欄位
        paint.carRenderer = (Renderer)EditorGUILayout.ObjectField("車身 Renderer", paint.carRenderer, typeof(Renderer), true);

        // 顏色欄位
        paint.carColor = EditorGUILayout.ColorField("車色", paint.carColor);

        EditorGUILayout.Space();

        // 一鍵套用顏色
        if (GUILayout.Button("套用車色"))
        {
            paint.ApplyColor();
        }

        if (GUI.changed)
        {
            EditorUtility.SetDirty(paint);
        }
    }
}
