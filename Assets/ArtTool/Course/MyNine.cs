using UnityEngine;

public class MyNine : MonoBehaviour
{

    void Start()
    {
        //這行是float 強制轉換成Int
        float a = 2.1f;
        int b = (int)a; //強制轉換類型 (要轉換的類型) 
        Debug.LogErrorFormat("a={0} b={1}", a, b);

        //這行是string 強制轉換成Int或是float
        //使用Parse 要很明確, 不然會報錯
        string s = "2";
        int c = int.Parse(s);
        Debug.LogErrorFormat("c={0}", c);

        //使用TryParse 錯了後,她不會報錯
        int d;
        int.TryParse("2.1", out d);

    }


}
