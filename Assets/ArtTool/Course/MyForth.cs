using Unity.Collections;
using Unity.VisualScripting;
using UnityEngine;

public class MyForth : MonoBehaviour
{
    public int Number_01, Number_02;

    void Start()
    {
        bool b = 5 > Number_01; //bool驗證類
        if (b)
        {
            var x = 1;
            var y = 2;
            x++;
            Debug.LogErrorFormat("x is {0},y  is {1}", x, y);
        }
        else
        {
            var k = 100;
            Debug.LogError(k);
        }
        //簡寫的if句型,?前面是條件 後面就是if 和else
        Number_01 = Number_01 > 2 ? ++Number_01 : --Number_01;
        Debug.LogError("Updated Number_01: " + Number_01);

        //比較 只要前面是假的後面就不會計算
        bool c = (1 == 3) && (2 == 2);
        Debug.LogError(c);


    }


}

