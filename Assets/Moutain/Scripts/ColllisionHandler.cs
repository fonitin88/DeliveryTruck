using UnityEngine;

public class ColllisionHandler : MonoBehaviour
{

    [SerializeField] GameObject destroyedVFX;
    GameSceneManeger gameSceneManeger;
    private void Start()
    {
        gameSceneManeger = FindFirstObjectByType<GameSceneManeger>();
    }

    void OnTriggerEnter(Collider other)
    {
        gameSceneManeger.ReloadLevel();
        Instantiate(destroyedVFX, transform.position, Quaternion.identity);
        Destroy(gameObject);
        //Debug.Log("Hit" + other.name);
        Debug.Log($"Hit{other.gameObject.name}");
    }
}
