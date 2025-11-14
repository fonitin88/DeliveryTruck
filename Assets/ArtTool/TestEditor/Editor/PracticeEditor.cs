using UnityEditor;
using UnityEngine;

public class PracticeEditor
{
    #region [成員]
    private bool isJumpFolder;
    #endregion
    public void Draw() //可以讓外部調用功能
    {
        if (GUILayout.Button("Path"))
        {
            var obj = Selection.activeObject;
            //點選物件 然後按button就會獲取path
            string path1 = AssetDatabase.GetAssetPath(obj);
            Debug.LogError(path1);
        }

        if (GUILayout.Button("Delete"))
        {
            var obj = Selection.activeObject;
            string path = AssetDatabase.GetAssetPath(obj); //獲取物件的路徑
            AssetDatabase.DeleteAsset(path);
        }

        if (GUILayout.Button("GUID"))
        {
            var obj = Selection.activeObject;
            string path = AssetDatabase.GetAssetPath(obj); //獲取物件的路徑          
            Debug.LogError(AssetDatabase.AssetPathToGUID(path));//把path 轉為GUID
        }

        if (GUILayout.Button("顯示開關"))
        {
            GameObject go = Selection.activeGameObject;
            go.SetActive(!go.activeSelf);//如果是假的就讓它變真的,真的就變假的
        }
        if (GUILayout.Button("改變static"))
        {
            GameObject go = Selection.activeGameObject;
            // StaticEditorFlags flags = StaticEditorFlags.ContributeGI | StaticEditorFlags.BatchingStatic; 
            //可以直接簡寫(StaticEditorFlags)5
            GameObjectUtility.SetStaticEditorFlags(go, (StaticEditorFlags)5);
        }
        if (GUILayout.Button("改變Tag"))
        {
            GameObject go = Selection.activeGameObject;
            go.tag = "EditorOnly";
        }
        if (GUILayout.Button("改變Layer"))
        {
            GameObject go = Selection.activeGameObject;
            go.layer = 4;
        }
        if (GUILayout.Button("獲取component的值"))
        {
            GameObject go = Selection.activeGameObject;
            Light light = go.GetComponentInChildren<Light>();//<>泛型
            Debug.LogError(light.intensity);
        }
        if (GUILayout.Button("新增物件"))
        {
            var go = GameObject.CreatePrimitive(PrimitiveType.Capsule);
            go.name = "test01";
            go.tag = "EditorOnly";
        }
        if (GUILayout.Button("新增component"))
        {
            GameObject go = Selection.activeGameObject;
            var light = go.AddComponent(typeof(Light)) as Light;
            light.intensity = 2;
        }
        if (GUILayout.Button("character folder"))
        {
            string _path = "Assets/Arts/Charater";
            Object _o = AssetDatabase.LoadAssetAtPath(_path, typeof(Object));
            Selection.activeObject = _o;
        }

        isJumpFolder = EditorGUILayout.BeginFoldoutHeaderGroup(isJumpFolder, "category");

        if (isJumpFolder) //如果三角形是展開的  就會出現按鈕
        {
            if (GUILayout.Button("Env Folder"))
            {
                string _path = "Assets/Arts/Env";
                string[] _guids = AssetDatabase.FindAssets("t:Object", new string[] { _path }); //有點間接指向裡面的第一個資料夾的GUID
                string _subPath = AssetDatabase.GUIDToAssetPath(_guids[0]);//GUID 轉成路徑
                Object _o = AssetDatabase.LoadAssetAtPath(_subPath, typeof(Object));
                Selection.activeObject = _o;

            }

        }
        EditorGUILayout.EndFoldoutHeaderGroup();
    }
}
