using UnityEditor.Experimental.GraphView;
using UnityEngine;


public class MySix : MonoBehaviour
{
    public Vector3 MyVector3; // xyz數值
    public Vector4 MyVector4;
    public Rect MyRect;

    void Start()
    {
        var t = new TestClass();
        t.WidthHeight = new Vector2(10, 20);
        Debug.LogError(t.WidthHeight.x);//只顯示其中一個直
        MyVector3 = new Vector3(1, 2, 3);
        MyVector4 = new Vector4(1, 2, 3, 4);
        // MyRect = new Rect(1, 2, 3, 4);
    }


}
class TestClass
{
    public Vector2 WidthHeight;

}

