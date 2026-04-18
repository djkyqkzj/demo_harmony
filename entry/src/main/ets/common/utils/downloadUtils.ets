import { Music, Play } from '../constants/Model';
import HttpRequest from '../http/HttpRequest';
import { StorageUtil } from '../utils/StorageUtil'

export interface DownloadTask {
  url: string | undefined;
  id: string | number | undefined;
  item?: Play;
}

export const checkDownloadLimit = async (): Promise<Music[]> => {
  const list: string = await StorageUtil.getString('downloadList', "");
  const playList: Music[] = JSON.parse(list || "[]");
  if (playList.length >= 30) {
    throw new Error('DOWNLOAD_LIMIT_REACHED');
  }
  return playList;
};

// Update local storage
export const updateLocalStorage = async (newData: Music): Promise<boolean> => {
  const localData: string = await StorageUtil.getString('downloadList', "");
  const localArr: Music[] = localData ? JSON.parse(localData) : [];
  localArr.push(newData);
  await StorageUtil.putString('downloadList', JSON.stringify(localArr));
  return true;
};

export const downloadPlaylist = async (playlistData: Music, onProgress?: (progress: number) => void): Promise<Music> => {
  try {
    await checkDownloadLimit();
    // Download cover image
    let coverImage: string = '';
    try {
      console.log('=====Downloading cover image:', playlistData.cover_image);
      coverImage = await HttpRequest.download(playlistData.cover_image, `${playlistData.id}`, 'png');
      console.log('=======Cover image downloaded successfully:', coverImage);
    } catch (coverError) {
      console.error('====Failed to download cover image:', coverError);
      // Use a fallback or rethrow the error
      throw new Error(`====Cover image download failed: ${coverError}`);
    }

    const date: Music = playlistData
    date.cover_image = coverImage
    const newData: Music = date

    // Prepare music download tasks
    const downloadTasks: DownloadTask[] = playlistData.musics!.map((item: Play): DownloadTask => ({
      url: item.music_address_2,
      id: item.id,
      item: item
    }));
    console.log('=====Starting music downloads, total tasks:', downloadTasks.length);
    // Use async pool to download music files
    let completedTasks = 0;
    await asyncPool(3, downloadTasks, async (task: DownloadTask): Promise<void> => {
      try {
        console.log(`=======Downloading music: ${task.id} from ${task.url}`);
        const musicUri: string = await HttpRequest.download(task.url, `${task.id}`, 'mp3');
        if (task.item) {
          task.item.local_music_address_2 = musicUri;
        }
        completedTasks++;
        console.log(`========Completed ${completedTasks}/${downloadTasks.length} music downloads`);

        // Update progress if callback provided
        if (onProgress) {
          const progress = completedTasks / downloadTasks.length;
          onProgress(progress);
        }
      } catch (musicError) {
        if (musicError instanceof Error) {
          throw musicError;
        } else {
        }// Re-throw to stop the entire process
      }
    });

    if (onProgress) {
      onProgress(1);
    }
    await updateLocalStorage(newData);

    return newData;
  } catch (error) {
    console.error('=======Download playlist error:', error);
    if (error instanceof Error) {
      throw error;
    } else {
      throw new Error('========Unknown download error occurred');
    }
  }
};

export const asyncPool = async (poolLimit: number, array: DownloadTask[], iteratorFn: (task: DownloadTask) => Promise<void>): Promise<void[]> => {
  const ret: Promise<void>[] = [];
  const executing: Set<Promise<void>> = new Set();

  for (const item of array) {
    const p: Promise<void> = Promise.resolve().then(() => iteratorFn(item));
    ret.push(p);
    executing.add(p);

    const clean = (): void => { executing.delete(p); };
    p.then(clean).catch(clean);

    if (executing.size >= poolLimit) {
      await Promise.race(executing);
    }
  }
  return Promise.all(ret);
};


export const isDownLoad = async (id: string | number): Promise<boolean> => {
  const list: string = await StorageUtil.getString('downloadList', "");
  const playList: Music[] = JSON.parse(list || "[]");
  if (playList.length === 0) {
    return false;
  } else {
    return playList.some((item: Music) => item.id === id);
  }
}

export const formatMusicData = (newData?: Music): string[] => {
  if (!newData || !Array.isArray(newData.musics) || newData.musics.length === 0) {
    return [];
  }
  const firstMusic: Play | undefined = newData.musics[0];
  const flag: boolean = !!firstMusic?.local_music_address_2;

  return newData.musics.map((i: Play): string => {
    const address: string | undefined = flag ? i?.local_music_address_2 : i?.music_address_2;
    return address || '';
  });
}