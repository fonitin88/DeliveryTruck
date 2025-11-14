using Unity.VisualScripting;
using UnityEngine;
[DisallowMultipleComponent] //不能同時使用多次
public class MyFirstCsharp : MonoBehaviour
{
    public int Number_01, Number_02;
    Calculator mySecond = new Calculator(); //實利化,如果沒有使用static的話

    public int A = 10;

    void Start()
    {

        // int sum01 = mySecond.Add(Number_01, Number_02);
        // print(sum01);
        // int sum02 = mySecond.Multi(Number_01, Number_02);
        // print(sum02);
        Test mytest = new Test();
        Add(out A, out mytest);
        print(A);
        print(mytest.B);
    }
    void Add(out int a, out Test t)
    {
        a = 5;
        a = a + 10;
        t = new Test();
        t.B = t.B + 10;
    }

}
class Test
{
    public int B = 20;
}
