import { Request, Response } from "express";
import fs from "fs";
import { GenerateService } from "../services/GenerateService";

class GenerateController {
  async handle(request: Request, response: Response): Promise<Response> {
    const { sources, start_date, end_date } = request.body;
    const avaiableSources = this.getAvaiableSources();
    const generateService = new GenerateService();

    if(!sources || !start_date || !end_date) {
      return response.status(400);
    }
  
    if(!this.checkSources(sources, avaiableSources)) {
      return response.status(400);
    }

    // generateService.generate({sources, start_date, end_date});

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


export { GenerateController };
