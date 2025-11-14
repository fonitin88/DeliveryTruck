
using UnityEditor;
using UnityEngine;


public class PrefabBrushEditor : EditorWindow
{
    GameObject prefab;
    float brushRadius = 2.0f;
    int density = 5;
    float spacing = 0.5f;
    bool alignToSurface = true;//地形貼合
    bool randomRotation = true;
    Vector2 randomScaleRange = new Vector2(1f, 1f);

    Vector3 hitPostion = Vector3.zero;
    Vector3 lastSpawnPos = Vector3.positiveInfinity;//無限大的初始值

    [MenuItem("Tools/BrushPrefab")]
    public static void Open()
    {
        GetWindow<PrefabBrushEditor>("Prefab Brush");
    }

    void OnGUI()
    {
        GUILayout.Label("Brush Setting", EditorStyles.boldLabel);
        prefab = (GameObject)EditorGUILayout.ObjectField("prefab", prefab, typeof(GameObject), false);
        brushRadius = EditorGUILayout.Slider("Brush Radius", brushRadius, 0.1f, 10f);
        density = EditorGUILayout.IntSlider("Density", density, 1, 20);
        spacing = EditorGUILayout.Slider("Spacing", spacing, 0.1f, 5f);
        alignToSurface = EditorGUILayout.Toggle("Align to Surface", alignToSurface);
        randomRotation = EditorGUILayout.Toggle("Random Rotation", randomRotation);
        randomScaleRange = EditorGUILayout.Vector2Field("Random Scale Range", randomScaleRange);
        EditorGUILayout.HelpBox("Press left mouse to brush", MessageType.Info);

    }
    void OnEnable()
    {
        SceneView.duringSceneGui += OnSceneGUI; //EditorWindow 與 SceneView 溝通
    }
    void OnDisable()
    {
        SceneView.duringSceneGui -= OnSceneGUI;
    }

    void OnSceneGUI(SceneView sceneView)
    {
        //讓畫面不會因點到別的而跑掉
        HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));
        //設定滑鼠
        Event e = Event.current;
        Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);

        // 如果射線有命中地面
        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            hitPostion = hit.point;

            //筆刷範圍
            Handles.color = Color.green;
            Handles.DrawWireDisc(hitPostion, Vector3.up, brushRadius);
            //筆刷中心點
            Handles.color = Color.red;
            Handles.DrawWireDisc(hitPostion, Vector3.up, 0.15f);


            if ((e.type == EventType.MouseDown && e.button == 0) ||
                (e.type == EventType.MouseDrag && e.button == 0))
            {
                // 確保不會太密集（距離超過 spacing 才生成）
                if (Vector3.Distance(hitPostion, lastSpawnPos) > spacing)
                {
                    spawnPrefabs(hitPostion);
                    lastSpawnPos = hitPostion;
                    e.Use();
                    Debug.Log("滑鼠命中位置：" + hit.point);
                }
            }
            // 滑鼠放開 → 重設距離檢查
            if (e.type == EventType.MouseUp)
            {
                lastSpawnPos = Vector3.positiveInfinity;
            }
        }

        SceneView.RepaintAll();
    }
    void spawnPrefabs(Vector3 center)
    {
        if (prefab == null)
        {
            Debug.LogWarning("請指定prefab");
        }
        Undo.IncrementCurrentGroup(); //undo組群組
        Undo.SetCurrentGroupName("Brush Spawn Prefabs");  // 給這組命名

        //開始生成
        for (int i = 0; i < density; i++)
        {
            //隨機位置
            Vector2 randomOffset = Random.insideUnitCircle * brushRadius;
            Vector3 spawnPos = center + new Vector3(randomOffset.x, 0, randomOffset.y);

            //檢查實際地面高處到低處（用 Raycast）
            if (Physics.Raycast(spawnPos + Vector3.up * 10f, Vector3.down, out RaycastHit groundHit, 20f))
            {
                GameObject newObj = (GameObject)PrefabUtility.InstantiatePrefab(prefab);
                Undo.RegisterCreatedObjectUndo(newObj, "spawn prefab");

                newObj.transform.position = groundHit.point;

                // 地形貼合（物件法線對齊地面法線）
                if (alignToSurface)
                {
                    newObj.transform.up = groundHit.normal;
                }

                // 隨機旋轉
                if (randomRotation)
                {
                    newObj.transform.Rotate(Vector3.up, Random.Range(0f, 360f), Space.World);
                }

                //隨機縮放
                float randomScale = Random.Range(randomScaleRange.x, randomScaleRange.y);
                newObj.transform.localScale *= randomScale;
            }



        }
        Undo.CollapseUndoOperations(Undo.GetCurrentGroup());

    }
}
