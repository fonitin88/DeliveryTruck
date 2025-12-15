using UnityEngine;
using UnityEngine.SceneManagement;

public static class SceneLoader
{
    public static string NextSceneName;

    public static void Load(string targetScene)
    {
        //讓sceneManger 使用 名稱而不是 Index 怕增加場景而忘了改
        NextSceneName = targetScene;
        //強制一定要先Loading 
        SceneManager.LoadScene("Loading");
    }
}
