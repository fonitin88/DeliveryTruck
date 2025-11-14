using System.Collections.Generic;
using UnityEditor;
using UnityEngine;

public class GroupEditor
{
    bool useStartsWith = true; // ✅ 預設使用 StartsWith
    string nameKeyword = "Prop";
    string[] fixednameKeyword = { "Prop", "Veg", "custom" };
    List<bool> enableGroups = new List<bool>();

    public void Draw()
    {

        //陣列的打勾
        GUILayout.Label("Group up", EditorStyles.boldLabel);
        EnsureToggleListSynced();
        for (int i = 0; i < fixednameKeyword.Length; i++)
        {
            enableGroups[i] = EditorGUILayout.Toggle(fixednameKeyword[i], enableGroups[i]);
        }

        // 🔍 檢查是否有勾選 custom
        int customIndex = System.Array.IndexOf(fixednameKeyword, "custom");
        if (customIndex >= 0 && enableGroups[customIndex])
        {
            useStartsWith = EditorGUILayout.Toggle("Match Prefix", useStartsWith);
            nameKeyword = EditorGUILayout.TextField("Name contain：", nameKeyword);
        }

        EditorGUILayout.Space();

        if (GUILayout.Button("Create"))
        {
            GroupPrefabs();
        }
    }
    void EnsureToggleListSynced() //陣列的bool初始值
    {
        while (enableGroups.Count < fixednameKeyword.Length)
            enableGroups.Add(false);
        Debug.Log($"➕ 補上 false，現在 enableGroups.Count = {enableGroups.Count}");
    }

    void GroupPrefabs()
    {
        GameObject[] allObjects = Object.FindObjectsByType<GameObject>(FindObjectsSortMode.None);

        for (int i = 0; i < fixednameKeyword.Length; i++)
        {
            if (!enableGroups[i]) continue;

            string keyword = fixednameKeyword[i];
            string groupLabel = keyword;
            bool isCustom = keyword == "custom";

            if (isCustom)//判斷是不是custom
            {
                keyword = nameKeyword;
                //如果忘了加名字 就會是 "CustomGroup"
                groupLabel = string.IsNullOrEmpty(nameKeyword) ? "CustomGroup" : nameKeyword;
            }

            List<GameObject> matchedObjects = new List<GameObject>();

            foreach (GameObject obj in allObjects)
            {
                if (!obj.scene.IsValid()) continue;

                var prefab = PrefabUtility.GetCorrespondingObjectFromOriginalSource(obj);

                bool isPrefabNameMatch = prefab != null &&
                    (isCustom && useStartsWith ? prefab.name.StartsWith(keyword) : prefab.name.Contains(keyword));

                bool isSceneNameMatch =
                    isCustom && useStartsWith ? obj.name.StartsWith(keyword) : obj.name.Contains(keyword);

                if (isPrefabNameMatch || isSceneNameMatch)
                {
                    matchedObjects.Add(obj);
                }
            }

            if (matchedObjects.Count == 0)
            {
                continue;
            }

            GameObject groupParent = new GameObject(groupLabel);
            Undo.RegisterCreatedObjectUndo(groupParent, "Create Group Root");

            foreach (var obj in matchedObjects)
            {
                Undo.SetTransformParent(obj.transform, groupParent.transform, "Group Object");
            }

        }
    }

}
