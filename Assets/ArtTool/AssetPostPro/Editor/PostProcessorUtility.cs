using UnityEngine;
using UnityEditor;
using System.IO; //path類的

public static class PostProcessorUtility
{
    public static void SetModelScene(this ModelImporter modelImporter)
    {
        modelImporter.globalScale = 1;
        modelImporter.useFileScale = true;
        modelImporter.bakeAxisConversion = false;
        modelImporter.importBlendShapes = false;
        modelImporter.importVisibility = false;
        modelImporter.importCameras = false;
        modelImporter.importLights = false;
        modelImporter.preserveHierarchy = false;
        modelImporter.sortHierarchyByName = false;
    }
    public static void SetModelMESH(this ModelImporter modelImporter, bool isAddCollider = false)
    {
        modelImporter.meshCompression = ModelImporterMeshCompression.Medium;
        modelImporter.isReadable = false;
        modelImporter.optimizeMeshPolygons = true;
        modelImporter.addCollider = isAddCollider;
    }

    public static void SetModelGeometry(this ModelImporter modelImporter, bool isImportNormal)
    {
        modelImporter.keepQuads = false;
        modelImporter.weldVertices = true;
        modelImporter.indexFormat = ModelImporterIndexFormat.Auto;
        if (isImportNormal)
        {
            modelImporter.importNormals = ModelImporterNormals.Import;
            modelImporter.importBlendShapeNormals = modelImporter.importNormals;
            modelImporter.normalCalculationMode = ModelImporterNormalCalculationMode.AreaAndAngleWeighted;
            modelImporter.normalSmoothingSource = ModelImporterNormalSmoothingSource.FromAngle;
            modelImporter.normalSmoothingAngle = 60;
            modelImporter.importTangents = ModelImporterTangents.CalculateMikk;
        }
        else
        {
            modelImporter.importNormals = ModelImporterNormals.None;
        }


        modelImporter.swapUVChannels = false;
        modelImporter.generateSecondaryUV = false;
        modelImporter.strictVertexDataChecks = false;
    }
    // 安裝C# XML documentation comments 在打///會出現的文字註釋
    /// <summary>
    /// 這是有關動畫的
    /// </summary>
    public static void SetAnimation(this ModelImporter modelImporter, bool isImportAnimation)
    {
        modelImporter.importConstraints = false;
        modelImporter.importAnimation = isImportAnimation;
        modelImporter.resampleCurves = true;
        modelImporter.animationCompression = ModelImporterAnimationCompression.KeyframeReductionAndCompression;
        modelImporter.importAnimatedCustomProperties = false;
    }

    public static void SetModelMaterial(this ModelImporter modelImporter)
    {
        modelImporter.materialImportMode = ModelImporterMaterialImportMode.ImportViaMaterialDescription;
        modelImporter.materialLocation = ModelImporterMaterialLocation.InPrefab;
        modelImporter.materialName = ModelImporterMaterialName.BasedOnMaterialName;
        modelImporter.materialSearch = ModelImporterMaterialSearch.RecursiveUp;
    }
}
