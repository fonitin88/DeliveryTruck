using JetBrains.Annotations;
using UnityEngine;
using UnityEngine.UI;

public class ColorController : MonoBehaviour
{
    [Header("References")]
    //把data view gameobj button 帶進去 
    public ColorData colorData;
    public ColorView colorView;
    public GameObject targetObject;
    public Button redBtn;
    public Button yellowBtn;
    public Button blueBtn;

    void Start()
    {
        //view中的物件

        // 從資料庫載入顏色和 更新顏色

        //按鈕寫上功能


    }
    //選了顏色後更新到data / view / save
    void OnColorSelected()
    {

    }

}
