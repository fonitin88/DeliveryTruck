using System;
using Unity.VisualScripting;
using UnityEngine;

public class MyThirdsharp : MonoBehaviour
{
    #region [成員變量]
    public int Number_01, Number_02;
    public string apname;
    #endregion

    #region [函數成員]
    void Start()
    {
        /*Satic的
        int sum = MySecond.Add(Number_01, Number_02);
        Debug.Log(sum);
        */
        var a1 = 1;
        var b1 = new Calculator();
        String str = "This is a terrible \t learning lesson.";
        Debug.Log(Number_01, this);
        Debug.Log(apname + Number_01);
        Debug.Log(str);
        Debug.LogFormat("Show the number {0} and {1}", Number_01, Number_02);
        Debug.LogError(a1);
    }
    #endregion

}

