class DownloadStore {
  private downloadingIds: number[] = [];
  private downloadedIds: number[] = [];

  setDownloadingIds(ids: number[]) {
    this.downloadingIds = ids;
  }

  addDownloadingId(id: number) {
    if (!this.downloadingIds.includes(id)) {
      this.downloadingIds.push(id);
    }
  }

  removeDownloadingId(id: number) {
    this.downloadingIds = this.downloadingIds.filter(item => item !== id);
  }

  setDownloadedIds(ids: number[]) {
    this.downloadedIds = ids;
  }

  addDownloadedId(id: number) {
    if (!this.downloadedIds.includes(id)) {
      this.downloadedIds.push(id);
      this.removeDownloadingId(id);
    }
  }

  getDownloadingIds() {
    return this.downloadingIds;
  }

  getDownloadedIds() {
    return this.downloadedIds;
  }
}

const downloadStore = new DownloadStore();

export default downloadStore;