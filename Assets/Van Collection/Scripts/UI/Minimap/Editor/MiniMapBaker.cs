#if UNITY_EDITOR
using UnityEditor;
using UnityEditor.Rendering.Universal.ShaderGUI;
using UnityEngine;

public class MiniMapBaker : EditorWindow
{
    int resolution = 256;
    //給工具一個初始範圍之後從 NavMesh 取得實際範圍
    Vector2 worldMin = new Vector2(-50, -50);
    Vector2 worldMax = new Vector2(50, 50);
    //來判斷可走 不可走區域
    float sampleRadius = 0.3f;
    //顏色
    public Color level0C = Color.white; //walkable
    public Color level1C = Color.yellow; //walkable border
    public Color level2C = Color.red; //nonwalkable border
    public Color level3C = Color.blue;//nonwalkable
    //border 寬度調整
    [Range(0f, 0.5f)]
    public float innerThickFraction = 0.15f;
    [Range(0f, 0.5f)]
    public float outerThickFraction = 0.15f;

    [MenuItem("Tools/MiniMap Baker")]
    public static void ShowWindow()
    {
        GetWindow<MiniMapBaker>("Minimap");
    }

    void OnGUI()
    {
        resolution = EditorGUILayout.IntField("Resolution", resolution);
        if (GUILayout.Button("計算範圍"))
        {
            ApplyNavMeshBounds();
        }
        worldMin = EditorGUILayout.Vector2Field("範圍起始點", worldMin);
        worldMax = EditorGUILayout.Vector2Field("範圍終點", worldMax);
        sampleRadius = EditorGUILayout.FloatField("掃描半徑", sampleRadius);
        GUILayout.Space(5);
        GUILayout.Label("顏色", EditorStyles.boldLabel);
        level0C = EditorGUILayout.ColorField("走道", level0C);
        level1C = EditorGUILayout.ColorField("走道邊緣", level1C);
        level2C = EditorGUILayout.ColorField("外圍邊緣", level2C);
        level3C = EditorGUILayout.ColorField("外圍", level3C);
        GUILayout.Space(5);
        GUILayout.Label("邊緣寬度");
        innerThickFraction = EditorGUILayout.Slider("走道邊緣寬度比", innerThickFraction, 0.1f, 0.5f);
        outerThickFraction = EditorGUILayout.Slider("外圍邊緣寬度比", outerThickFraction, 0.1f, 0.5f);
        if (GUILayout.Button("預設"))
        {
            innerThickFraction = 0.15f;
            outerThickFraction = 0.15f;
            GUI.changed = true;
        }
        GUILayout.Space(5);
        if (GUILayout.Button("Bake MiniMap"))
        {
            Bake();
        }
    }


    void ApplyNavMeshBounds()
    {

    }
    void Bake()
    {

    }
}
#endif