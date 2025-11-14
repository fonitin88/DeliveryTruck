using UnityEditor;
using UnityEngine;

public class PrefabPreviewTool : EditorWindow
{
    //先把功能叫出來(就像是把需要的器材先拿出來)
    GameObject prefab;
    PreviewRenderUtility previewRender; //預覽窗
    GameObject previewInstance;  //預覽窗的物件

    Vector2 orbitAngles = new Vector2(120f, -20f);
    float zoom = 1.0f; // 以模型大小為基準的相對距離
    float baseDistance = 3f; // 根據模型 bounds 計算出來的基準距離


    [MenuItem("Tools/PrefabPreview Tool")]
    public static void ShowWindow()
    {
        GetWindow<PrefabPreviewTool>("PrefabPreview Tool");
    }

    void OnGUI()
    {
        //prefab 拖進去
        prefab = (GameObject)EditorGUILayout.ObjectField("prefab", prefab, typeof(GameObject), true);


        //繪製的區域
        Rect previewRect = GUILayoutUtility.GetRect(position.width - 10, position.width - 10, GUILayout.ExpandWidth(false));
        EditorGUI.DrawRect(previewRect, Color.gray);


        if (prefab != null && previewInstance != null)
        {
            HandleMouseInput(previewRect); // 處理滑鼠旋轉與縮放
            DrawPreview(previewRect);//準備render場景和拍攝
        }
        else
        {
            GUI.Label(previewRect, "請按『重新載入』預覽 Prefab",
            new GUIStyle()
            {
                alignment = TextAnchor.MiddleCenter,
                normal = { textColor = Color.white }
            }
            );
        }



        //重設載入
        if (GUILayout.Button("重新載入") && prefab != null)
        {
            CreatePreviewInstance();
        }

        //清除
        if (GUILayout.Button("清除預覽"))
        {
            ClearPreview();
        }

    }

    void DrawPreview(Rect rect) //PreviewRenderUtility
    {

        //開始準備渲染BeginPreview
        previewRender.BeginPreview(rect, GUIStyle.none);

        // 使用 orbitAngles 與 zoom 控制相機
        Quaternion rotation = Quaternion.Euler(orbitAngles.y, -orbitAngles.x, 0);
        //旋轉預覽相機
        Vector3 camPos = rotation * (Vector3.back * (baseDistance * zoom));

        previewRender.camera.transform.position = camPos;
        previewRender.camera.transform.rotation = rotation;
        //確保相機永遠對準中心模型
        previewRender.camera.transform.LookAt(Vector3.zero);

        //拍攝模型
        previewRender.camera.Render();
        //結束EndPreview
        Texture result = previewRender.EndPreview();

        //顯示在編輯器上
        GUI.DrawTexture(rect, result, ScaleMode.ScaleToFit, false);
    }

    void HandleMouseInput(Rect rect) //rect 預覽方框
    {
        //設定事件
        Event e = Event.current;
        //滑鼠不在預覽區域
        if (!rect.Contains(e.mousePosition))
            return;
        //if滑鼠效果
        if (e.type == EventType.MouseDrag && e.button == 0)
        {
            orbitAngles.x += e.delta.x * 0.5f; // 左右拖曳旋轉
            orbitAngles.y -= e.delta.y * 0.5f; // 上下拖曳旋轉
            orbitAngles.y = Mathf.Clamp(orbitAngles.y, -80f, 80f); // 限制垂直角度
            Repaint();
        }
        //else if 滾輪效果
        else if (e.type == EventType.ScrollWheel)
        {
            zoom += e.delta.y * 0.05f;
            zoom = Mathf.Clamp(zoom, 0.3f, 3f); // 限制縮放範圍
            Repaint();
        }
    }

    void CreatePreviewInstance()
    {
        ClearPreview();

        //初始化區塊 建立 PreviewRenderUtility渲染環境
        previewRender = new PreviewRenderUtility();// 就去拿一個放進去
        previewRender.camera.clearFlags = CameraClearFlags.Color; //要先清洗鍋子(清空)
        previewRender.camera.backgroundColor = Color.gray; //才能放背景色
        previewRender.cameraFieldOfView = 30f; //放入攝影機


        //用previewRender來放置物件
        previewInstance = (GameObject)previewRender.InstantiatePrefabInScene(prefab);
        //並予以位置
        previewInstance.transform.position = Vector3.zero;

        // 可以計算模型大小來調整初始距離
        Bounds b = CalculateBounds(previewInstance);
        baseDistance = b.extents.magnitude * 3f;

        //給予燈光
        // previewRender.lights[0].intensity = 1.3f;
        // previewRender.lights[0].transform.rotation = Quaternion.Euler(30f, 30f, 0f);
        // previewRender.lights[1].intensity = 0.6f;

    }

    Bounds CalculateBounds(GameObject go)
    {
        Renderer[] renderers = go.GetComponentsInChildren<Renderer>();
        Bounds bounds = new Bounds(go.transform.position, Vector3.zero);
        foreach (Renderer r in renderers)
            bounds.Encapsulate(r.bounds);
        return bounds;
    }

    void ClearPreview()
    {
        //預覽窗物件=Null
        if (previewRender != null)
        {
            previewRender.Cleanup();//清除
            previewRender = null;
        }
        //預覽窗=null
        if (previewInstance != null)
        {
            Object.DestroyImmediate(previewInstance);//清除物件
            previewInstance = null;
        }

    }
    void OnDisable()
    {
        ClearPreview();
    }

}
