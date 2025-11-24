#if UNITY_EDITOR
using UnityEditor;
using UnityEditorInternal;
using UnityEngine;

public class EnvSpawnWindow : EditorWindow
{
    private SpawnSettings settings;
    private Vector2 scroll;
    private Terrain sceneTerrain; //這是場景的 Terrain 

    [MenuItem("Tools/Terrain Spawn")]
    public static void ShowWindow()
    {
        GetWindow<EnvSpawnWindow>("Terrain Spawn");
    }

    private void OnGUI()
    {
        EditorGUILayout.LabelField("Terrain Poisson 分散生成工具", EditorStyles.boldLabel);
        EditorGUILayout.Space();

        settings = (SpawnSettings)EditorGUILayout.ObjectField("Spawn Settings", settings, typeof(SpawnSettings), false);

        if (!settings)
        {
            if (GUILayout.Button("建立 SpawnSettings"))
                CreateSettingsAsset();
            return;
        }

        DrawBasicSettings();
        DrawPrefabSettings();
        DrawRegionGrid();
        DrawButtons();

        if (GUI.changed)
            EditorUtility.SetDirty(settings);
    }

    void DrawBasicSettings()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("基本設定", EditorStyles.boldLabel);

        sceneTerrain = (Terrain)EditorGUILayout.ObjectField("Terrain", sceneTerrain, typeof(Terrain), true);

        settings.gridXCount = Mathf.Max(1, EditorGUILayout.IntField("Grid X", settings.gridXCount));
        settings.gridYCount = Mathf.Max(1, EditorGUILayout.IntField("Grid Y", settings.gridYCount));

        settings.totalSpawnCount = Mathf.Max(0, EditorGUILayout.IntField("Total Count", settings.totalSpawnCount));

        settings.collisionMask = LayerMaskField("Collision Mask", settings.collisionMask);

        settings.parentRoot = (Transform)EditorGUILayout.ObjectField("群組名稱", settings.parentRoot, typeof(Transform), true);
    }

    void DrawPrefabSettings()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("生成 Prefab", EditorStyles.boldLabel);

        settings.prefab = (GameObject)EditorGUILayout.ObjectField(
            "Prefab",
            settings.prefab,
            typeof(GameObject),
            false
        );
    }

    void DrawRegionGrid()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("Grid 區域密度", EditorStyles.boldLabel);

        if (GUILayout.Button("重建 Grid"))
        {
            Undo.RecordObject(settings, "Rebuild Grid");
            settings.RebuildRegions();
        }

        if (settings.regions.Count == 0)
        {
            EditorGUILayout.HelpBox("沒有 Regions，請按『重建 Grid』", MessageType.Warning);
            return;
        }

        scroll = EditorGUILayout.BeginScrollView(scroll, GUILayout.Height(200));

        for (int y = 0; y < settings.gridYCount; y++)
        {
            EditorGUILayout.BeginHorizontal();
            for (int x = 0; x < settings.gridXCount; x++)
            {
                var r = settings.GetRegion(x, y);

                EditorGUILayout.BeginVertical(GUILayout.Width(60));
                EditorGUILayout.LabelField($"{x},{y}", GUILayout.Width(60));
                r.density = EditorGUILayout.Slider(r.density, 0f, 1f, GUILayout.Width(60));
                EditorGUILayout.EndVertical();
            }
            EditorGUILayout.EndHorizontal();
        }

        EditorGUILayout.EndScrollView();
    }

    void DrawButtons()
    {
        EditorGUILayout.Space();
        EditorGUILayout.LabelField("操作", EditorStyles.boldLabel);

        EditorGUILayout.BeginHorizontal();
        if (GUILayout.Button("Generate"))

        {
            if (sceneTerrain == null)
            {
                EditorUtility.DisplayDialog("錯誤", "請先指定場景中的 Terrain", "OK");
            }
            else
            {
                SpawnController.Generate(settings, sceneTerrain);
            }
        }

        if (GUILayout.Button("Clear"))
            SpawnController.ClearGenerated(settings);
        EditorGUILayout.EndHorizontal();
    }

    LayerMask LayerMaskField(string label, LayerMask mask)
    {
        var layers = InternalEditorUtility.layers;
        var layerNumbers = new int[layers.Length];

        for (int i = 0; i < layers.Length; i++)
            layerNumbers[i] = LayerMask.NameToLayer(layers[i]);

        int maskWithoutEmpty = 0;
        for (int i = 0; i < layerNumbers.Length; i++)
            if ((mask.value & (1 << layerNumbers[i])) > 0)
                maskWithoutEmpty |= (1 << i);

        int newMask = EditorGUILayout.MaskField(label, maskWithoutEmpty, layers);
        int newMaskValue = 0;

        for (int i = 0; i < layers.Length; i++)
            if ((newMask & (1 << i)) > 0)
                newMaskValue |= (1 << layerNumbers[i]);

        mask.value = newMaskValue;
        return mask;
    }

    void CreateSettingsAsset()
    {
        string defaultFolder = "Assets/Van Collection/Scripts";
        string path = EditorUtility.SaveFilePanelInProject("建立 SpawnSettings", "SpawnSettings", "asset", "選擇位置", defaultFolder);
        if (!string.IsNullOrEmpty(path))
        {
            var asset = ScriptableObject.CreateInstance<SpawnSettings>();
            asset.RebuildRegions();
            AssetDatabase.CreateAsset(asset, path);
            settings = asset;
            EditorGUIUtility.PingObject(asset);
        }
    }
}
#endif
