import { ISource } from "../sources/ISource";

interface IImportFinancialContent {
  sources: ISource[];
  startDate: Date;
  endDate: Date;
}

class ImportFinancialContentService {
  import({ sources, startDate, endDate }: IImportFinancialContent): void {
    
  }
}

export { ImportFinancialContentService };
