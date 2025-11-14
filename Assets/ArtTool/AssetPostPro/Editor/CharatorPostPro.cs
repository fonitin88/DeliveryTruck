using UnityEngine;
using UnityEditor;
using System.IO; //path類的

//這個是動作的導入選項
public class CharatorPostPro : AssetPostprocessor
{
    //const 常量是固定 且 不能修改
    const string PATH = "Assets/Arts/Charater/";
    //當所有資源被導入時都會執行
    //強制設定 外部無法修改
    void OnPreprocessModel()
    {
        //assetPath 指導入的路徑
        //Contains(這路徑內的都要執行,少一個都是不符合)
        if (assetPath.Contains(PATH))
        {

            ModelImporter modelImporter = (ModelImporter)assetImporter;
            string name = Path.GetFileName(assetPath);
            modelImporter.SetModelScene();//寫一個class 都通用
            modelImporter.SetModelMESH();
            modelImporter.SetModelGeometry(true);

            //以下是rig設置
            modelImporter.animationType = ModelImporterAnimationType.Generic;
            modelImporter.avatarSetup = ModelImporterAvatarSetup.NoAvatar;
            modelImporter.skinWeights = ModelImporterSkinWeights.Standard;

            //以下是動態設置 文件有@ 就判定
            if (name.Contains("@"))
            {
                modelImporter.SetAnimation(true);

                //如果是動畫文件 就不需要材質
                modelImporter.materialImportMode = ModelImporterMaterialImportMode.None;
            }
            else
            {
                modelImporter.SetAnimation(false);
                //如果是模型就匯入材質
                modelImporter.SetModelMaterial();
            }
        }

        Debug.LogErrorFormat("assetPath:{0}", assetPath);
        Debug.LogErrorFormat("GetDirectoryName:{0}", Path.GetDirectoryName(assetPath));//有很多方法 可以獲得不同路徑

    }


}
