using UnityEngine;

public class MyEight : MonoBehaviour
{

    void Start()
    {
        int a = TestA.Add(3, 8);
        Debug.LogError(a);
        Log(c: "嗨", a: 2, b: 1.5f);//命名參數 可以不用照順序
    }
    void Log(int a, float b, string c)
    {
        Debug.LogErrorFormat("a:{0},b:{1},c:{2}", a, b, c);//命名參數 可以不用照順序
    }



}
class TestA
{
    //[]這是代表數組的意思 多組數字
    public static int Add(params int[] values)//參數 int[] values：接收到的參數會存成數組
    //values 是變數名稱，你可以自由取名。int[] 是型別，表示這個變數是一個整數陣列，不能改變型別。
    //型別（int、string、int[]）一定要放在變數名稱前面
    {
        int sum = 0;
        for (int i = 0; i < values.Length; i++)
        {
            sum += values[i];
        }
        return sum;
    }
}
