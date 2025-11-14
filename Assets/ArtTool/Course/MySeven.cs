using UnityEditor.Experimental.GraphView;
using UnityEngine;
using System;


public class MySeven : MonoBehaviour
{
    #region [成員]
    public int[] Number = new int[3] { 0, 1, 2 };//一維數組,規定數組:後面的實體化是規定多少數組
    public int[,] NumberA = new int[2, 3] { { 2, 3, 4 }, { 5, 6, 7 } };//多為數組 unity顯示不支援
    public int[] NumberB = { 15, 28, 31, 45, 55, 69 }; //後面可以直接簡寫{}

    #endregion

    void Start()
    {
        Debug.LogErrorFormat("數組索引{0}的元素值為{1}", 1, Number[1]);
        for (int i = 0; i < 2; i++) //for循環，初始值;條件;符合結果後,每次迴圈結束後才執行的
        {
            Debug.LogErrorFormat("i是{0}", i);
        }
        for (int i = 0, j = 10; i < 3; i++, j += 10) //for循環 裡面又加其他數值
        {
            Debug.LogErrorFormat("{0}:{1}", i, j);
        }
        for (int i = 1; i < 5; i++) //for循環 顯示數組的數字
        {
            Debug.LogErrorFormat("{0}:{1}", i, NumberB[i]);
        }

        Array.Clear(NumberB, 3, 3); //從第三開始清除數字
        for (int i = 1; i < NumberB.Length; i++) //for循環 條件中組數的長度
        {
            Debug.LogErrorFormat("第{0}是:{1}", i, NumberB[i]);
        }
        for (int i = 0; i < NumberA.Rank; i++) // 多數數組的for
        {
            for (int j = 0; j < NumberA.GetLength(1); j++) //0代表行 1代表列
            {
                Debug.LogErrorFormat("第{0}第{1}列的是{2}", i, j, NumberA[i, j]);
            }


        }

    }


}


