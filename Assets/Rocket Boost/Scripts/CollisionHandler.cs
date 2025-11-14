using System;
using UnityEngine;
using UnityEngine.InputSystem;
using UnityEngine.SceneManagement;
public class CollisionHandler : MonoBehaviour
{
    [SerializeField] float levelLoadDelay = 2f;
    [SerializeField] AudioClip successSFX;
    [SerializeField] AudioClip crashSFX;
    [SerializeField] ParticleSystem successVFX;
    [SerializeField] ParticleSystem crashVFX;

    AudioSource audioSource;//把音響播放器取一個名字

    bool isControllable = true;
    bool isCollidable = true;

    private void Start()
    {
        audioSource = GetComponent<AudioSource>();//需要一個音響播放器

    }

    private void Update()
    {
        ResponToDebugKeys();
    }
    void ResponToDebugKeys()//按按鍵跳轉場景
    {
        if (Keyboard.current.lKey.wasPressedThisFrame)
        {
            LoadNextLevel();
        }
        else if (Keyboard.current.cKey.wasPressedThisFrame)
        {
            isCollidable = !isCollidable;//布林反轉,切換開關,開/關碰撞偵測
        }
    }

    private void OnCollisionEnter(Collision other)
    {
        if (!isControllable || !isCollidable) { return; }// 開關碰撞處理
        switch (other.gameObject.tag)
        {
            case "Start"://這是Tag
                Debug.Log("start");
                break;
            case "Finish"://這是Tag,碰到去下個場景
                FinishSequence();
                break;
            case "Fuel"://這是Tag
                Debug.Log("pick me up");
                break;
            default://剩下的
                StartCrashSequence();
                Debug.Log("crash object: " + other.gameObject.name);
                break;

        }

    }

    void StartCrashSequence()
    {
        //碰到，就會變成 false
        isControllable = false;

        // audioSource.Stop();
        // audioSource.PlayOneShot(crashSFX);
        crashVFX.Play();
        GetComponent<Movement>().enabled = false; //當碰撞到就會停止移動
        Invoke("ReloadLevel", levelLoadDelay);//延遲載入
    }

    void FinishSequence()
    {
        //碰到 Finish，就會變成 false
        isControllable = false;

        // audioSource.Stop();
        //audioSource.PlayOneShot(successSFX);
        successVFX.Play();
        GetComponent<Movement>().enabled = false; //當碰撞到就會停止移動
        Invoke("LoadNextLevel", levelLoadDelay);//延遲載入
    }

    void ReloadLevel()
    {
        int currentScene = SceneManager.GetActiveScene().buildIndex;//指定是現在的場景
        SceneManager.LoadScene(currentScene);//碰撞後 會從這個場景在重新開始
    }

    void LoadNextLevel()
    {
        int currentScene = SceneManager.GetActiveScene().buildIndex;
        int nextScene = currentScene + 1;
        if (nextScene == SceneManager.sceneCountInBuildSettings)//sceneCountInBuildSettings 場景的總數
        {
            nextScene = 0;
        }
        SceneManager.LoadScene(nextScene);
    }


}
