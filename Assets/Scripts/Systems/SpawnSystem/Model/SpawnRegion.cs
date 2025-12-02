using System;
using UnityEngine;

[Serializable]
public class SpawnRegion
{
    public Vector2Int gridIndex;
    [Range(0f, 1f)]
    public float density = 0f;
}
