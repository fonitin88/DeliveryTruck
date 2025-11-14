using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class ReplaceEditor
{
    GameObject prefabToReplace;

    public void Draw()
    {
        GameObject selectedSceneObject = Selection.activeGameObject;

        EditorGUILayout.LabelField("Scene Object：", EditorStyles.boldLabel);
        if (selectedSceneObject != null && selectedSceneObject.scene.IsValid())
        {
            EditorGUILayout.ObjectField(selectedSceneObject, typeof(GameObject), true);
        }
        else
        {
            EditorGUILayout.HelpBox("請在場景中選擇一個 prefab 實例。", MessageType.Warning);
        }

        EditorGUILayout.Space();

        EditorGUILayout.LabelField("Drag the New prefab：", EditorStyles.boldLabel);
        prefabToReplace = (GameObject)EditorGUILayout.ObjectField(prefabToReplace, typeof(GameObject), false);

        EditorGUILayout.Space();

        // ✅ 按鈕 1
        GUI.enabled = selectedSceneObject != null && prefabToReplace != null;
        if (GUILayout.Button("🔁 Replace Selected item"))
        {
            ReplaceSingle(selectedSceneObject);
        }

        EditorGUILayout.Space();

        // ✅ 按鈕 2
        if (GUILayout.Button("🔁 Replace All"))
        {
            ReplaceAllSamePrefab(selectedSceneObject);
        }

        GUI.enabled = true;
    }

    void ReplaceSingle(GameObject target)
    {
        GameObject newObj = Replace(target);
        Selection.activeGameObject = newObj;
    }

    void ReplaceAllSamePrefab(GameObject referenceObj)
    {
        // 找出參考物件的 prefab 來源
        var sourcePrefab = PrefabUtility.GetCorrespondingObjectFromOriginalSource(referenceObj);
        GameObject[] allSceneObjects = Object.FindObjectsByType<GameObject>(FindObjectsSortMode.None);

        int count = 0;
        List<GameObject> replacedList = new List<GameObject>();

        foreach (var obj in allSceneObjects)
        {
            var objSource = PrefabUtility.GetCorrespondingObjectFromOriginalSource(obj);
            if (objSource == sourcePrefab)
            {
                GameObject newObj = Replace(obj);
                replacedList.Add(newObj);
                count++;
            }
        }

        Selection.objects = replacedList.ToArray();
    }

    GameObject Replace(GameObject target)
    {
        Transform t = target.transform;
        Vector3 pos = t.position;
        Quaternion rot = t.rotation;
        Transform parent = t.parent;
        Vector3 scale = t.localScale;

        //按 Ctrl+Z就能復原
        Undo.RegisterFullObjectHierarchyUndo(target, "Replace With Prefab");

        Object.DestroyImmediate(target);

        GameObject newObj = (GameObject)PrefabUtility.InstantiatePrefab(prefabToReplace);
        newObj.transform.SetPositionAndRotation(pos, rot);
        newObj.transform.parent = parent;
        newObj.transform.localScale = scale;

        return newObj;
    }

}
