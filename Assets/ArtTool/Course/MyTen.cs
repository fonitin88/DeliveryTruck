using UnityEngine;

public class MyTen : MonoBehaviour
{
    //枚舉 用戶自定義類型,常量的一種
    public enum CustomColor
    {
        White,
        Black,
        Red,
        Green,
        Yellow,
    }
    public CustomColor c = CustomColor.Black;
    void Start()
    {
        if (c == CustomColor.Black)
        {
            Debug.LogError("黑色");
        }
        else
        {
            Debug.LogError("彩色");
        }

        Debug.LogError(TestClass3.value);


        switch (c) //分支
        {
            case CustomColor.Black:
                {
                    Debug.LogError(1);
                }
                break; //匹配結果後 會直接跳出這個switch判斷式

            case CustomColor.Green:
                Debug.LogError(5);
                break;

            case CustomColor.Red:
            case CustomColor.White:
                Debug.LogError("彩色");
                break;

            default:
                Debug.LogError("查無結果");
                break;
        }
    }
    class TestClass3
    {
        //const 常量是固定 且 不能修改, 必須一開始就要給他一個數值
        public const int value = 99;
    }

}
