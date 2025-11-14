using Unity.VisualScripting;
using UnityEditor;
using UnityEngine;

[CustomEditor(typeof(SceneViewDemo))]
public class SceneViewDemoEditor : Editor
{
    Vector3 startPos;
    bool isDrawing = false;

    void OnSceneGUI()
    {
        SceneViewDemo tool = (SceneViewDemo)target;
        Event e = Event.current;

        // 防止 Scene 視窗搶事件（特別是選取和拖曳）
        // HandleUtility.AddDefaultControl(GUIUtility.GetControlID(FocusType.Passive));

        Handles.color = Color.green;

        //左鍵按下/0 代表左鍵 → 開始畫
        if (e.type == EventType.MouseDown && e.button == 0 && !isDrawing)
        {
            startPos = GetMouseWorldPos(e);
            if (startPos != Vector3.zero)
            {
                isDrawing = true;
                e.Use();
            }
        }

        //正在畫
        if (isDrawing)
        {
            Vector3 currentPos = GetMouseWorldPos(e);

            Vector3 center = (startPos + currentPos) / 2f;
            Vector3 size = new Vector3(Mathf.Abs(startPos.x - currentPos.x), 0, Mathf.Abs(startPos.z - currentPos.z));

            Handles.DrawWireCube(center, size);

            // 放開滑鼠 → 儲存方框資料
            if (e.type == EventType.MouseUp && e.button == 0)
            {
                isDrawing = false;
                Undo.RecordObject(tool, "Set Box Area");
                tool.center = center;
                tool.size = size;
                Debug.Log($"方框完成：中心 {center} 大小 {size}");
                e.Use();

            }

            SceneView.RepaintAll();
        }

        // 如果已有範圍 → 長期顯示
        if (tool.size != Vector3.zero)
        {
            Handles.color = Color.red;
            Handles.DrawWireCube(tool.center, tool.size);
            Handles.Label(tool.center + Vector3.up * 0.5f, $"中心: {tool.center}\n大小: {tool.size}");
        }

    }

    //override OnInspectorGUI 加入按鈕
    public override void OnInspectorGUI()
    {
        base.OnInspectorGUI();
        SceneViewDemo tool = (SceneViewDemo)target; //目標的選取物件
        if (GUILayout.Button("Generate Objects"))
        {
            tool.GanerateObjects();
        }
    }


    //把滑鼠座標轉成世界座標
    Vector3 GetMouseWorldPos(Event e)
    {
        //把 Scene 視窗的滑鼠座標轉成 Ray（射線）
        Ray ray = HandleUtility.GUIPointToWorldRay(e.mousePosition);
        //從 Scene 發射射線，碰到哪裡就回傳那個位置
        if (Physics.Raycast(ray, out RaycastHit hit))
        {
            return hit.point;
        }
        return Vector3.zero;
    }
}

