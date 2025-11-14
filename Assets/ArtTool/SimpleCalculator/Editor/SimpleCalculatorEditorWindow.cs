using UnityEditor; //這個編輯器下開發的
using UnityEngine;

public class SimpleCalculatorEditorWindow : EditorWindow
{
    #region 
    private static GUISkin skin;
    private string NumberLabel = "0";
    private string DisplayShow = "結果顯示";
    private int Number01, Number02;
    private string op;
    #endregion

    [MenuItem("Tools/Simple Calculator #r", false)] //寫在Menu裡面 中間是快捷鍵, sort in the end
    static void Open() //關於介面的
    {
        var window = GetWindow(typeof(SimpleCalculatorEditorWindow), false, "簡易計算機");
        window.Show();
        window.minSize = new Vector2(200, 100); //最小視窗尺寸
        window.maxSize = new Vector2(900, 800);//如果要固定的話 就設定一樣數值
        window.position = new Rect(new Vector2(), new Vector2(500, 500)); //開啟的位置,(,)可輸入position和size
        Texture tex = AssetDatabase.LoadAssetAtPath<Texture>("Assets/ArtTool/SimpleCalculator/Editor/home.png");
        window.titleContent = new GUIContent("計算機", tex, "這是簡單"); //跟第一行的命名的功能一樣,但還可以加上圖片and提示

        skin = (GUISkin)EditorGUIUtility.Load("Assets/ArtTool/SimpleCalculator/Editor/Calculator.guiskin");
    }

    //下方bool的作用 讓特定對象去使用這個功能,ex點選這個,功能才會啟用
    [MenuItem("Tool/Simple Calculator #r", true)]
    static bool TestValidate()
    {
        return Selection.activeGameObject != null; //選擇的object 不是空的
    }


    void OnGUI()
    {
        //使用GUIStyle
        GUIStyle _style01 = new GUIStyle(EditorStyles.textField);//先實利化 之後才能去做使用,EditorStyles.textField 輸入框效果
        _style01.fontSize = 25;
        _style01.wordWrap = true;//隨著字型大小調整畫面
        EditorGUILayout.LabelField(DisplayShow, _style01);

        //使用GUILayout
        if (GUILayout.Button("Enter", GUILayout.Width(100), GUILayout.Height(50))) //按鈕
        {
            DisplayShow = "歡迎使用";
        }

        //使用GUISkin
        GUI.skin = skin; //這樣就可以直接寫("box") 不用(skin.box)
        EditorGUILayout.LabelField(NumberLabel, style: "textField");

        EditorGUILayout.BeginHorizontal();
        {
            EditorGUILayout.BeginVertical("box");
            {
                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("7", "button"))
                {
                    if (NumberLabel == "0")
                        NumberLabel = "7";
                    else
                        NumberLabel += "7";
                }
                if (GUILayout.Button("8", "button"))
                {
                    if (NumberLabel == "0")
                        NumberLabel = "8";
                    else
                        NumberLabel += "8";
                }
                if (GUILayout.Button("9", "button"))
                {
                    //三元運算子（Ternary Operator） 條件 ? 結果1 : 結果2;
                    //如果 條件為真，則執行 結果1。如果 條件為假，則執行 結果2。
                    NumberLabel = NumberLabel == "0" ? "9" : NumberLabel + "9";
                }
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("4", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "4" : NumberLabel += "4";
                }
                if (GUILayout.Button("5", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "5" : NumberLabel += "5";
                }
                if (GUILayout.Button("6", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "6" : NumberLabel += "6";
                }
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("1", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "1" : NumberLabel += "1";
                }
                if (GUILayout.Button("2", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "2" : NumberLabel += "2";
                }
                if (GUILayout.Button("3", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "3" : NumberLabel += "3";
                }
                EditorGUILayout.EndHorizontal();

                EditorGUILayout.BeginHorizontal();
                if (GUILayout.Button("0", "button"))
                {
                    NumberLabel = NumberLabel == "0" ? "0" : NumberLabel += "0";
                }
                if (GUILayout.Button("c", "button"))
                {
                    NumberLabel = "0";
                }
                if (GUILayout.Button("=", "button"))
                {
                    Number02 = int.Parse(NumberLabel); //把string類型 轉換成數值類型
                    if (op == "+")
                    {
                        int r = Number01 + Number02; //目前是數值類型
                        NumberLabel = r.ToString(); //把數值類型 轉換成string類型

                    }
                    else if (op == "-")
                    {
                        int r = Number01 - Number02;
                        NumberLabel = r.ToString();
                    }
                    else if (op == "*")
                    {
                        int r = Number01 * Number02;
                        NumberLabel = r.ToString();
                    }
                    else if (op == "/")
                    {
                        if (Number02 != 0)
                        {
                            int r = Number01 / Number02;
                            NumberLabel = r.ToString();
                        }
                        else
                        {
                            NumberLabel = "0";
                        }

                    }
                }
                EditorGUILayout.EndHorizontal();
            }
            EditorGUILayout.EndVertical();

            EditorGUILayout.BeginVertical(skin.box);
            {
                if (GUILayout.Button("+", "button"))
                {
                    Number01 = int.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "+";
                }
                if (GUILayout.Button("-", "button"))
                {
                    Number01 = int.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "-";
                }
                if (GUILayout.Button("*", "button"))
                {
                    Number01 = int.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "*";
                }
                if (GUILayout.Button("/", "button"))
                {
                    Number01 = int.Parse(NumberLabel);
                    NumberLabel = "0";
                    op = "/";
                }
            }
            EditorGUILayout.EndVertical();
        }

        EditorGUILayout.EndHorizontal();



    }
}
