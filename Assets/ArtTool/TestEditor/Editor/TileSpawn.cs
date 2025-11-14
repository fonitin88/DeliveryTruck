using System;
using UnityEditor;
using UnityEngine;

public class TileSpawn
{

    GameObject prefabToSpawn;

    int spawnAmount = 1;
    int space = 1;
    int rows = 1;


    public void Draw()
    {
        EditorGUILayout.LabelField("Prefab:", EditorStyles.boldLabel);
        prefabToSpawn = (GameObject)EditorGUILayout.ObjectField(prefabToSpawn, typeof(GameObject), true);
        spawnAmount = Math.Max(1, EditorGUILayout.IntField("Amount", spawnAmount)); //不能讓他negative 
        space = EditorGUILayout.IntField("Space", space);
        rows = EditorGUILayout.IntField("rows", rows);
        EditorGUILayout.Space();
        if (GUILayout.Button("Spawn"))
        {
            spawnPrefab();
        }
        if (GUILayout.Button("Delete"))
        {
            deleteGroup();
        }

    }
    void spawnPrefab()
    {
        GameObject parent = GameObject.Find("Group");
        if (parent == null)
        {
            parent = new GameObject("Group");
        }

        for (int x = 0; x < spawnAmount; x++)
        {
            for (int z = 0; z < rows; z++)
            {
                GameObject newPrefab = (GameObject)PrefabUtility.InstantiatePrefab(prefabToSpawn);
                newPrefab.transform.position = new Vector3(x * space, 0, z * space);//先往Z軸排
                newPrefab.transform.SetParent(parent.transform);
            }
        }
    }
    void deleteGroup()
    {
        GameObject parent = GameObject.Find("Group");
        if (parent)
        {
            UnityEngine.Object.DestroyImmediate(parent);
        }
    }
}
