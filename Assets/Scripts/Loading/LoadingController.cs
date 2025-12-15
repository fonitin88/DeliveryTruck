using System.Collections;
using TMPro;
using UnityEngine;
using UnityEngine.SceneManagement;
using UnityEngine.UI;

public class LoadingController : MonoBehaviour
{
    [SerializeField] Slider progressBar;
    [SerializeField] TMP_Text loadingtex;
    IEnumerator Start()
    {
        // 讓第一關剛載入的尖峰先緩一下
        yield return null;
        yield return null;

        //嘗試釋放沒用的資源，降低切scene尖峰
        Resources.UnloadUnusedAssets();
        System.GC.Collect();

        //防呆
        string next = SceneLoader.NextSceneName;
        if (string.IsNullOrEmpty(next))
        {
            next = "Menu";
        }

        var op = SceneManager.LoadSceneAsync(next);
        op.allowSceneActivation = false;

        while (!op.isDone)
        {
            float p = Mathf.Clamp01(op.progress / 0.9f);

            if (loadingtex) loadingtex.text = $"{p * 100f}%";

            if (progressBar) progressBar.value = p;
            if (op.progress >= 0.9f)
            {
                if (progressBar) progressBar.value = 1f;
                op.allowSceneActivation = true;
            }
            yield return null;
        }

    }


}
