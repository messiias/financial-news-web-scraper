import fs from "fs";
import { Request, Response } from "express";
import { ImportFinancialContentService } from "../services/ImportFinancialContentService";

class ImportFinancialContentController {
  async handle(request: Request, response: Response): Promise<Response> {
    const { sources, startDate, endDate } = request.body;
    const avaiableSources = this.getAvaiableSources();
    const generateService = new ImportFinancialContentService();

    if(!sources || !startDate || !endDate) {
      return response.status(400);
    }
  
    if(!this.checkSources(sources, avaiableSources)) {
      return response.status(400);
    }

    generateService.import({sources, startDate, endDate});

    return response.status(200);
  }

  private checkSources(
    requestedSources: Array<string>,
    avaiableSources: Array<string>
  ): Boolean {
    return requestedSources.some(source => avaiableSources.includes(source))
  }

  private getAvaiableSources(): Array<string> {
    let avaiableSources: Array<string>;

    fs.readdir("../sources", (_err, files) => {
      avaiableSources = files.map(file => file.toLowerCase())
    });

    return avaiableSources;
  }
}


export { ImportFinancialContentController };
