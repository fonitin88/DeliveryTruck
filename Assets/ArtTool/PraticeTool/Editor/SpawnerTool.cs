using UnityEditor;
using UnityEngine;

public class SpawnerTool : EditorWindow
{
    GameObject prefabToSpawn;
    Vector3 spawnPosition = Vector3.zero;

    [MenuItem("Tools/Spawner Tool")]
    public static void ShowWindow()
    {
        GetWindow<SpawnerTool>("Spawner Tool");
    }

    void OnGUI()
    {
        GUILayout.Label("Spawn Settings", EditorStyles.boldLabel);

        // 選擇要生成的 Prefab
        prefabToSpawn = (GameObject)EditorGUILayout.ObjectField("Prefab", prefabToSpawn, typeof(GameObject), false);

        // 設定生成位置
        spawnPosition = EditorGUILayout.Vector3Field("Spawn Position", spawnPosition);

        if (GUILayout.Button("Spawn"))
        {
            if (prefabToSpawn != null)
            {
                GameObject obj = (GameObject)PrefabUtility.InstantiatePrefab(prefabToSpawn);
                obj.transform.position = spawnPosition;

                // 自動掛上 Rotator Script
                if (obj.GetComponent<Rotator>() == null)
                    obj.AddComponent<Rotator>();
            }
            else
            {
                Debug.LogWarning("請先指定 Prefab！");
            }
        }
    }
}
