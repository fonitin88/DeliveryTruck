using UnityEditor.Experimental.GraphView;
using UnityEngine;


public class MyFifth : MonoBehaviour
{

    void Start()
    {
        var P = new PassTest();
        P.Point = -50;
        Debug.LogError(P.Point);//這段開始有點亂
        var T = new PassTestStruct(55);//括號裡有沒有數值都無所謂
    }


}
class PassTest
{
    private int scoreA;
    public int Point
    {
        //get 可讀 set 可寫
        get { return scoreA; }
        set
        {
            if (value >= 0 && value <= 100)
            {
                scoreA = value;
            }
            else
            {
                Debug.LogError("分數錯誤");

            }

        }
    }
}
struct PassTestStruct
{
    public int Point;
    public PassTestStruct(int scoreB) //struct函數一定要有數值,class 則不一定
    {
        Point = scoreB;
    }
}
