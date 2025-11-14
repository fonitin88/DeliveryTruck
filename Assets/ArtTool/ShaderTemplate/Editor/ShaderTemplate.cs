using UnityEngine;
using UnityEditor;
using System.IO;

public class ShaderTemplate : EditorWindow
{
    [MenuItem("Assets/Create/Shader/Unlit UBP Shader")]
    public static void Init()
    {
        //使用GUID轉為路徑.抓取資料
        string shaderGUID = "748f368dde663264cb75a446ffe5d3b2";
        string path = AssetDatabase.GUIDToAssetPath(shaderGUID);

        //先選擇資料夾，然後獲取新的路徑
        var guid = Selection.assetGUIDs[0];//資料夾的GUID
        string foldPath = AssetDatabase.GUIDToAssetPath(guid);//把GUID轉為路徑
        //判斷是否為資料夾,不是的話就會該物件資料夾 新增
        if (!AssetDatabase.IsValidFolder(foldPath))
        {
            foldPath = Path.GetDirectoryName(foldPath);
        }
        //把newPath 填入獲取的路徑
        string newPath = foldPath + "/UnlitURP.shader";
        newPath = AssetDatabase.GenerateUniqueAssetPath(newPath); //重複的話 會自動生成1 2...
        AssetDatabase.CopyAsset(path, newPath);
    }
}
