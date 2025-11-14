using UnityEngine;
using UnityEditor;
using System.IO; //path類的
//這個是場景物件
public class MapPostPro : AssetPostprocessor
{
    //const 常量是固定 且 不能修改
    const string PATH = "Assets/Arts/";
    //當所有資源被導入時都會執行
    void OnPreprocessModel()
    {
        //assetPath 指導入的路徑
        //Contains(這路徑內的都要執行,少一個都是不符合)
        if (assetPath.Contains(PATH))
        {
            Debug.LogError(assetPath);
            ModelImporter modelImporter = (ModelImporter)assetImporter;
            //強制設定 外部無法修改
            modelImporter.SetModelScene();//寫一個class 都通用
            modelImporter.SetModelMESH();
            modelImporter.SetModelGeometry(true);

            //以下是rig and animation設置
            modelImporter.animationType = ModelImporterAnimationType.None;
            modelImporter.importAnimation = false;
            //如果是模型就匯入材質
            modelImporter.SetModelMaterial();

        }
    }

    void OnPostprocessMaterial(Material material)
    {
        //material.shader = Shader.Find("Unlit/Texture"); 可以設定自己自己寫的shader
    }
}
