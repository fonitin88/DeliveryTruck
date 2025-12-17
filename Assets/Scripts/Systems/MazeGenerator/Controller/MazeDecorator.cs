#if UNITY_EDITOR
using System.Collections.Generic;

using UnityEditor;
using UnityEngine;

public static class MazeDecorator
{
    public static void Decorate(
        Transform mazeRoot,
        IList<GameObject> decorationPrefabs,
        float density,
        float OffsetMin,
        float OffsetMax,
        float ScaleMin,
        float ScaleMax)
    {
        if (mazeRoot == null || decorationPrefabs == null || decorationPrefabs.Count == 0)
        {
            Debug.LogWarning("MazeDecorator.Decorate: mazeRoot 或 decorationPrefabs 沒設好。");
            return;
        }

        var walls = mazeRoot.GetComponentsInChildren<MazeWallMarker>();
        if (walls == null || walls.Length == 0)
        {
            Debug.LogWarning("MazeDecorator.Decorate: 找不到任何 MazeWallMarker 牆。");
            return;
        }

        // 所有裝飾都塞進這個 child 底下，之後好清
        Transform decorationsRoot = GetOrCreateGlobalRoot("Decorations");

        foreach (var wall in walls)
        {
            // density 越大 → 越容易放裝飾
            if (Random.value > density)
                continue;

            Transform t = wall.transform;
            // 先抓 Renderer，看牆有多厚
            var rend = t.GetComponentInChildren<Renderer>();
            if (rend == null)
                continue;
            //牆的厚度
            Vector3 size = rend.bounds.size;

            float halfThickness = Mathf.Min(size.x, size.z) * 0.5f;

            // 先決定方向：優先用 normal，沒有就退回用 transform.right
            Vector3 side = -wall.normal.normalized;

            float offsetFromWall = Random.Range(OffsetMin, OffsetMax);
            // 從牆中心往外推：先推到牆外側，再加上你設定的 offsetFromWall
            Vector3 pos = t.position + side * (halfThickness + offsetFromWall);

            //scale
            float randomScale = Random.Range(ScaleMin, ScaleMax);

            // 選一個 prefab
            var prefab = decorationPrefabs[Random.Range(0, decorationPrefabs.Count)];
            if (prefab == null) continue;

            //var instance = Object.Instantiate(prefab, pos, Quaternion.identity, decorationsRoot);
            var instance = (GameObject)PrefabUtility.InstantiatePrefab(prefab, decorationsRoot);
            instance.transform.SetPositionAndRotation(pos, Quaternion.identity);
            instance.transform.localScale = prefab.transform.localScale * randomScale;
        }
    }

    // 刪掉 mazeRoot 底下的 "_Decorations" 內所有小孩
    public static void ClearDecorations()
    {
        var child = GameObject.Find("Decorations");
        if (child == null) return;

        for (int i = child.transform.childCount - 1; i >= 0; i--)
        {
            Object.DestroyImmediate(child.transform.GetChild(i).gameObject);
        }
    }

    //  如果場景裡已經有 "_Decorations" 就拿來用，沒有就新建一個在 Root
    private static Transform GetOrCreateGlobalRoot(string name)
    {
        GameObject existing = GameObject.Find(name);
        if (existing != null)
            return existing.transform;

        GameObject go = new GameObject(name);
        return go.transform;
    }

}
#endif