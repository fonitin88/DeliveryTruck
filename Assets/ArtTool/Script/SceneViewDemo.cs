
using UnityEngine;

public class SceneViewDemo : MonoBehaviour
{
    public Vector3 center;
    public Vector3 size; //方框的長和寬
    public GameObject prefab;
    public int count = 10;

    //生成物件邏輯
    public void GanerateObjects()
    {
        if (prefab == null)
        {
            Debug.LogWarning("請放物件");
            return;
        }
        for (int i = 0; i < count; i++)
        {
            //隨機在中心點往左右上下延伸的範圍
            //center.x-size.x/2 最小值 center.x+size.x/2最大值
            Vector3 randomPos = new Vector3(
                Random.Range(center.x - size.x / 2, center.x + size.x / 2),
                center.y,
                Random.Range(center.z - size.z / 2, center.z + size.z / 2)
                );
            Instantiate(prefab, randomPos, Quaternion.identity);
        }
    }
}
