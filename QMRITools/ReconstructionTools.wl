(* ::Package:: *)

(* ::Title:: *)
(*QMRITools ReconstructionTools*)


(* ::Subtitle:: *)
(*Written by: Martijn Froeling, PhD*)
(*m.froeling@gmail.com*)


(* ::Section:: *)
(*Begin Package*)


BeginPackage["QMRITools`ReconstructionTools`", Join[{"Developer`"}, Complement[QMRITools`$Contexts, {"QMRITools`ReconstructionTools`"}]]];


(* ::Section:: *)
(*Usage Notes*)


(* ::Subsection:: *)
(*Functions*)


ReadListData::usage = 
"ReadListData[file] reads a list/data raw data file from the philips MR platform. The input file can either be .list or .data file.
Ouput is {{rawData, noise}, {head, types}}."


MeanType::usage = 
"MeanType[kspace, types, type] calcualtes the Mean of the kspace data on type, where type is part of types. The kspace and types are generated by ReadListData.
MeanType[{kspace, types}, type] calcualtes the Mean of the kspace data on type, where type is part of types.
MeanType[kspace, types, {type,..}] calcualtes the Mean of the kspace data on each of the list type, where type is part of types.
Output is {kspace, types}."

TotalType::usage = 
"TotalType[kspace, types, type] calcualtes the Total of the kspace data on type, where type is part of types. The kspace and types are generated by ReadListData.
TotalType[{kspace, types}, type] calcualtes the Total of the kspace data on type, where type is part of types.
TotalType[kspace, types, {type,..}] calcualtes the Total of the kspace data on each of the list type, where type is part of types.
Output is {kspace, types}."

OrderKspace::usage = 
"OrderKspace[kspace, types, order] reorders the kspace data to order, where order is a list and each value is a part of types. The kspace and types are generated by ReadListData."

SagitalTranspose::usage = 
"SagitalTranspose[data] makes a transpose of the data of the second level ande reverses the slices."


FourierShift::usage = 
"FourierShift[data] shift the data to the right by half the data dimensions."

InverseFourierShift::usage = 
"InvserseFourierShift[data] shift the data to the left by half the data dimensions."

ShiftedFourier::usage = 
"ShiftedFourier[kpace] performs a FourierTransform on the kspace and then shifts the data half the data dimensions."

ShiftedInverseFourier::usage = 
"ShiftedInverseFourier[data] shifts the data half the data dimensions and then performs a InverseFourierTransform on the data."

FourierShifted::usage = 
"FourierShifted[kspace] shifts the kspace half the kspace dimensions and then performs a FourierTransform on the kspace."

InverseFourierShifted::usage = 
"InverseFourierShifted[data] performs a InverseFourierTransform on the data and then shifts the kspace half the kspace dimensions."

FourierKspace2D::usage = 
"FourierKspace2D[kspace,head] performs a 2D reconstruction of 2D kspace data. Where kspace and head are generated by ReadListData."

FourierKspaceCSI::usage = 
"FourierKspaceCSI[kspace,head] performs a 3D reconstruction of 3D CSI kspace data. Where kspace and head are generated by ReadListData."


NoiseCorrelation::usage = 
"NoiseCorrelation[noise] calculates the noise correlation matrix, noise is {nrCoils, noise Samples}."

NoiseCovariance::usage = 
"NoiseCovariance[noise] calculates the noise covariance matrix, noise is {nrCoils, noise Samples}."


CoilCombine::usage = 
"CoilCombine[sig] combines the coil signals sig. Where sig is {nCoils, ...}.  
CoilCombine[sig, cov] combines the coil signals sig. Where sig is {nCoils, ...} and cov the complex noise correlation matrix.
CoilCombine[sig, cov, sens] combines the coil signals sig. Where sig is {nCoils, ...} and cov the complex noise correlation matrix and sense the coils sensitivitys.

Possible coil combination methods are \"Sum\", \"RootSumSqaures\", \"RoemerEqualNoise\", \"RoemerEqualSignal\", \"WSVD\".
RootSumSquares needs the signal. Can be performed with and without the noise covaricance matrix
RoemerEqualNoise needs the signal and the noise covaricance matrix. Can be performed with and without the sense data, without sense data the sensisity is estimated using the singal and the RSS reconstrucntion of the signa.
RoemerEqualSignal needs the signal and the noise covaricance matrix and the sense data.
WSVD needs the signal and the noise covariance matrix."

NormalizeSpectra::usage = 
"NormalizeSpectra[spec] normalizes spectra to be scaled to the max value of the absolute signal = 1000. Can be any dimension." 

MakeSense::usage = 
"MakeSense[coils, cov] makes a sense map for coils. Each coil signal is devided by the RSS reconstuction of the coils."


MakeHammingFilter::usage = 
"MakeHammingFilter[xdim] makes a 1D HammingKernel for filtering k-space.
MakeHammingFilter[{xdim}] makes a 1D HammingKernel for filtering k-space.
MakeHammingFilter[{xdim, ydim}] makes a 2D HammingKernel for filtering k-space in 2D CSI data of size {xdim, ydim}.
MakeHammingFilter[{xdim, ydim, zdim}] makes a 3D HammingKernel for filtering k-space in 3D CSI data of size {xdim, ydim, zdim}."

HammingFilterData::usage = 
"HammingFilterData[kspace] apllies a Hammingfilter to the data. The data is in immage space and can be 1D, 2D or 3D."

HammingFilterCSI::usage = 
"HammingFilterCSI[kspace] apllies a Hammingfilter to the k-space data. The data can be can be 1D, 2D or 3D, the spectral dimensions is the last dimensions (x,y,z, spectra)."


DenoiseCSIdata::usage = 
"DenoiseCSIdata[spectra] perfroms PCA denoising of the complex values spectra, data has to be 3D and the spectral dimensions is last, {x,y,z,spectra}."

DeconvolveCSIdata::usage = 
"DeconvolveCSIdata[spectra] deconvolves the CSI spectra after HammingFilterCSI to revert the blurring of the hammingfiltering." 

FourierRescaleData::usage = 
"FourierRescaleData[data] rescales the data to double the dimensions using zeropadding in fourier space. 
FourierRescaleData[data, facotr] rescales the data to factor times the dimensions using zeropadding in fourier space."


(* ::Subsection:: *)
(*Options*)


(* ::Subsection:: *)
(*Error Messages*)


(* ::Section:: *)
(*Functions*)


Begin["`Private`"] 


(* ::Subsection::Closed:: *)
(*Read List Data*)


SyntaxInformation[ReadListData]={"ArgumentsPattern"->{_}}

ReadListData[file_]:=Block[{
	fl,head,list,data,lab,dataIndex,dataVals,dataValsN,ruleKx,ruleKy,ruleKz,ruleCoil,
	typ,pos,dataSplit,indexSplit, echo,
	sizeInd,size,ind,off,noise,indData,nSamp,kspace,line,types,outData,outHead},
	
	fl=StringReplace[file,{".list"->"",".data"->""}];
	If[!FileExistsQ[fl<>".list"]||!FileExistsQ[fl<>".data"],Print["files not found"]];
	
	(*read the data - longest part*)
	list=ReadList[fl<>".list",String];
	data=BinaryReadList[fl<>".data","Complex64"];

	(*Get the header*)
	head=StringSplit/@Select[list,StringTake[#,1]==="."&];
	head = (p = Position[#, ":"][[1, 1]]; 
	     StringRiffle[#[[5 ;; (p - 1)]]] -> 
	      ToExpression[#[[(p + 1) ;;]]]) & /@ head;
	head[[All,2]]=If[Length[#]==1,#[[1]],#]&/@head[[All,2]];
	(*get the labels*)
	lab=StringSplit[list[[StringPosition[StringJoin[StringTake[#,1]&/@list],"# "][[1,1]]-2]]][[2;;-2]];
	
	(*parse text table*)
	dataIndex=Transpose[StringSplitExp[Select[list,StringTake[#,1]===" "&]]];(*longest part*)
	
	(*create header values*)
	dataVals=Thread[lab->(Sort[DeleteDuplicates[#]]&/@dataIndex)];
	dataValsN=Thread["N_"<>#&/@dataVals[[All,1]]->Length/@dataVals[[All,2]] ];
	dataVals[[All,2]]=If[Length[#]==1,#[[1]],#]&/@dataVals[[All,2]];
	
	(*Create rules for values that are not a normal range. eg kspace index or coil numbers*)
	If[MemberQ[lab,"kx"],ruleKx=Thread[("kx"/.dataVals)->(Range["N_kx"/.dataValsN]-1)]];
	ruleKy=Thread[("ky"/.dataVals)->(Range["N_ky"/.dataValsN]-1)];
	ruleKz=Thread[("kz"/.dataVals)->(Range["N_kz"/.dataValsN]-1)];
	ruleCoil=Thread[("chan"/.dataVals)->(Range["N_chan"/.dataValsN]-1)];
	
	(*partition raw data per k-line*)
	data=DynamicPartition[data,dataIndex[[-1]]/8];(*longest part*)
	
	(*split the data and index for data type*)
	typ=("typ"/.dataVals[[1]]);
	pos=Flatten@Position[dataIndex[[1]],#]&/@typ;
	dataSplit=Thread[typ->(data[[#]]&/@pos)];
	indexSplit=Thread[typ->(dataIndex[[All,#]]&/@pos)];
	
	(*get the number of sample in the data data*)
	nSamp=("STD"/.indexSplit)[[-1,1]]/8;
	AppendTo[dataValsN,"N_samp"->nSamp];
	
	(*get the data size*)
	sizeInd={"N_kx","N_ky","N_kz","N_chan","N_dyn","N_card","N_echo","N_loca","N_mix","N_extr1","N_extr2","N_aver","N_samp"};
	sizeInd=Select[sizeInd,MemberQ[dataValsN[[All,1]],#]&];
	size=sizeInd/.dataValsN;
	(*get the types with dimensions > 1*)
	types=Pick[sizeInd,Unitize[size-1],1];
	
	(*process noise data *)
	noise="NOI"/.dataSplit;
	
	(*get acepterd sample data and index*)
	data=("STD"/.dataSplit);
	ind=sizeInd[[;;-2]]/.Thread["N_"<>#&/@lab->Range[Length[lab]]];
	indData=("STD"/.indexSplit)[[ind]];
	
	(*reverse even echo*)
	echo=1-Mod[indData[[Position[sizeInd,"N_echo"][[1,1]]]],2];
	data=MapThread[If[#2==0,Reverse@#,#]&,{data,echo}];
	
	(*convert the index values to array values*)
	off=If[MemberQ[lab,"kx"],1,0];
	If[MemberQ[lab,"kx"],indData[[1]]=indData[[1]]/.ruleKx;];
	indData[[1+off]]=indData[[1+off]]/.ruleKy;
	indData[[2+off]]=indData[[2+off]]/.ruleKz;
	indData[[3+off]]=indData[[3+off]]/.ruleCoil;
	indData=Transpose[indData+1];
	
	(*create squeezed k-space*)
	Clear[line];
	kspace=ReplacePart[ConstantArray[line,size[[;;-2]]],Thread[indData->data]];(*longest part*)
	line=ConstantArray[0.+0.I,nSamp];
	kspace=Squeeze[kspace];
	size=Dimensions[kspace];
	Clear[line];
	
	(*print output*)
	Print["Datatypes in data: ",("typ"/.dataVals[[1]])];
	Print[Column[Prepend[StringJoin/@Thread[{"  - ",types,": ",ToString/@size}],"The data contains: "]]];
	
	(*define output*)
	outHead={Join[dataVals,dataValsN,head],types};(*General*)
	outData={kspace,noise};
	
	(*output*)
	{outData,outHead}
]


(*split string en convert to expression*)
StringSplitExp[strings_]:=System`Convert`TableDump`ParseTable[StringCases[strings,Except[WhitespaceCharacter]..][[All,;;-2]],{{"",""},{"-","+"},"."},False]


(* ::Subsection:: *)
(*Raw Data manipulation*)


(* ::Subsubsection::Closed:: *)
(*Mean over type*)


SyntaxInformation[MeanType]={"ArgumentsPattern"->{_,_,_.}}

(*Mean over list of values*)
MeanType[list_,type_,posS_List]:=Fold[MeanType,{list,type},posS]
(*Mean such that output and input match*)
MeanType[{list_,type_},posS_String]:=MeanType[list,type,posS]
(*single evaluation of mean*)
MeanType[list_,type_,posS_String]:=Block[{pos},
	(*Print[type];*)
	pos=posS/.Thread[type->Range[Length[type]]];
	(*Print["mean over: ",posS," (",pos")"];*)
	If[IntegerQ[pos],{MeanAt[list,pos],Drop[type,{pos}]},$Failed]
]


(* ::Subsubsection::Closed:: *)
(*Total over type*)


SyntaxInformation[TotalType]={"ArgumentsPattern"->{_,_,_.}}

(*Mean over list of values*)
TotalType[list_,type_,posS_List]:=Fold[TotalType,{list,type},posS]
(*Mean such that output and input match*)
TotalType[{list_,type_},posS_String]:=TotalType[list,type,posS]
(*single evaluation of mean*)
TotalType[list_,type_,posS_String]:=Block[{pos},
	(*Print[type];*)
	pos=posS/.Thread[type->Range[Length[type]]];
	(*Print["mean over: ",posS," (",pos")"];*)
	If[IntegerQ[pos],{TotalAt[list,pos],Drop[type,{pos}]},$Failed]
]


(* ::Subsubsection::Closed:: *)
(*Order K-space*)


SyntaxInformation[OrderKspace]={"ArgumentsPattern"->{_,_,_.}}

(*put kspace in requested order*)
OrderKspace[kspace_,type_,order_]:=OrderKspace[{kspace,type},order]
OrderKspace[{kspace_,type_},order_]:=Block[{mis},
mis=If[!MemberQ[type,#],#,Nothing]&/@order;
	If[mis==={},
		{Transpose[kspace,Flatten[(Position[order,#1]&)/@type]],order},
	Print["the types ",mis," are missing"]
]]


(* ::Subsubsection::Closed:: *)
(*Sagittal Transpose*)


SyntaxInformation[SagitalTranspose]={"ArgumentsPattern"->{_}}

SagitalTranspose[data_]:=(Reverse[Transpose[#1],2]&)/@data;


(* ::Subsection:: *)
(*Fourier Functions*)


(* ::Subsubsection::Closed:: *)
(*FourierShift*)


SyntaxInformation[FourierShift]={"ArgumentsPattern"->{_}}

FourierShift[data_]:=RotateRight[data,Floor[Dimensions[data]/2]];


(* ::Subsubsection::Closed:: *)
(*FourierShift*)


SyntaxInformation[InverseFourierShift]={"ArgumentsPattern"->{_}}

InverseFourierShift[data_]:=RotateLeft[data,Floor[Dimensions[data]/2]];


(* ::Subsubsection::Closed:: *)
(*Shift Data*)


ShiftData[data_,shift_]:=RotateRight[data,Reverse[shift]];


(* ::Subsubsection::Closed:: *)
(*Fourier Functions*)


SyntaxInformation[ShiftedFourier]={"ArgumentsPattern"->{_}}

ShiftedFourier[time_]:=FourierShift[Fourier[time,FourierParameters->{-1,1}]];


SyntaxInformation[ShiftedInverseFourier]={"ArgumentsPattern"->{_}}

ShiftedInverseFourier[spec_]:=InverseFourier[InverseFourierShift[spec],FourierParameters->{-1,1}];


SyntaxInformation[FourierShifted]={"ArgumentsPattern"->{_}}

FourierShifted[time_]:=Fourier[FourierShift[time],FourierParameters->{-1,1}];


SyntaxInformation[InverseFourierShifted]={"ArgumentsPattern"->{_}}

InverseFourierShifted[spec_]:=InverseFourierShift[InverseFourier[spec,FourierParameters->{-1,1}]];


(* ::Subsubsection::Closed:: *)
(*FourierKspace2D*)


SyntaxInformation[FourierKspace2D] = {"ArgumentsPattern" -> {_, _}};

FourierKspace2D[kspace_, head_] := Block[{ksPad, dim, imPad, shift, kspaceP, imData},
	(*get the oversampling padding*)
	ksPad = pp2 = Round[({"Y-resolution", "X-resolution"} {"ky_oversample_factor", "kx_oversample_factor"} - {"N_ky", "N_samp"})/2 /. head];
	(*get the final data dimentions*)
	dim = {"number_of_locations", "Y-resolution", "X-resolution"} /. head;
	(*get the image shift*)
	shift = s2 = Total[#] & /@ ({"Y_range", "X_range"} /. head);
    (*pad the kaspaces with zeros*)
    kspaceP = ArrayPad[#, Transpose@{ksPad, ksPad}, 0. + 0. I] & /@ kspace;
    (*get the image padding and image shift*)
    imPad = kp2 = -(Dimensions[kspaceP] - dim)/2;
    (*perform the fourie transform*)
    imData = ArrayPad[ShiftData[FourierShifted[#], shift] & /@ kspaceP, Transpose[{imPad, imPad}]]
  ]



(* ::Subsubsection::Closed:: *)
(*FourierKspaceCSI*)


SyntaxInformation[FourierKspaceCSI] = {"ArgumentsPattern" -> {_, _}}

FourierKspaceCSI[kspace_,head_]:=Block[{ksPad,dim,imPad,shift,kspaceP,imData},
	(*get the oversampling padding*)
	ksPad=Round[({"Z-resolution","Y-resolution","X-resolution"}{"kz_oversample_factor","ky_oversample_factor","kx_oversample_factor"}-{"N_kz","N_ky","N_kx"})/2/.head];
	(*get the final data dimentions*)
	dim={"Z-resolution","Y-resolution","X-resolution"}/.head;
	(*pad the kaspaces with zeros*)
	kspaceP=ArrayPad[#,Transpose@{ksPad,ksPad},0.+0.I]&/@kspace;
	(*get the image padding and image shift*)
	shift=Total[#]&/@({"Z_range","Y_range","X_range"}/.head);
	(*perform the fourie transform*)
	imData=ShiftData[FourierShift[FourierShifted[#]],shift]&/@kspaceP
]


(* ::Subsection::Closed:: *)
(*NoiseCorrelation*)


SyntaxInformation[NoiseCorrelation]={"ArgumentsPattern" -> {_}}

NoiseCorrelation[noise_] := Correlation[Transpose[noise]]


(* ::Subsection::Closed:: *)
(*NoiseCovariance*)


SyntaxInformation[NoiseCovariance]={"ArgumentsPattern" -> {_}}

NoiseCovariance[noise_] := Covariance[Transpose[noise]]


(* ::Subsection:: *)
(*CoilCombine*)


(* ::Subsubsection::Closed:: *)
(*CoilCombine*)


Options[CoilCombine] = {Method -> "RoemerEqualNoise"};

SyntaxInformation[CoilCombine] = {"ArgumentsPattern" -> {_, _., _., OptionsPattern[]}};

CoilCombine[sig_, opts : OptionsPattern[]] := CoilCombine[sig, 1, 1, opts]

CoilCombine[sig_, cov_, opts : OptionsPattern[]] := CoilCombine[sig, cov, 1, opts]

CoilCombine[sig_, cov_, sen_, OptionsPattern[]] := Block[{met,rec, sigt, sent, covi},
	
	met=OptionValue[Method];
	(*put ncoils as last dimensions*)
	sigt = If[ArrayDepth[sig] > 1, 
		If[met==="WSVD"||met==="WSVD2",
			If[ArrayDepth[sig]==2,sig,TransData[TransData[Transpose[sig],"l"],"l"]],
			TransData[sig, "l"]
		],sig];
	
	sent = If[ArrayDepth[sen] > 1, TransData[sen, "l"], sen];
	(*inverse noise cov*)
	If[cov=!=1, covi = Inverse[cov]];
	(*perform ND reconstruction for (coils, ND)*)
	rec = Switch[OptionValue[Method],
		"Average", MeanCombine[sig],
		"RootSumSquares", If[covi === 1, RSSCombine[sigt], RSSCovCombine[sigt, covi]],
		"RoemerEqualNoise", If[covi === 1, $Failed,If[sen === 1, 
			RoemerNCombine[sigt, MakeSense[Mean[sigt], cov], covi], 
			RoemerNCombine[sigt, sent, covi]]
			],
		"RoemerEqualSignal", If[covi === 1 || sen === 1, $Failed, RoemerSCombine[sigt, sent, covi]],
		"WSVD", If[covi === 1, $Failed, WSVDCombine[sigt, cov]],
		"WSVD2", If[covi === 1, $Failed, WSVDCombine2[sigt, cov]],
		_, Return[$Failed]
	];
	rec
]


(* ::Subsubsection::Closed:: *)
(*RSS*)


MeanCombine[sig_] := Mean[sig];

RSSCombine = Compile[{{sig, _Complex, 1}}, Abs@Sqrt[sig.Conjugate[sig]],
   RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];

RSSCovCombine = Compile[{{sig, _Complex, 1}, {cov, _Complex, 2}}, Abs@Sqrt[sig.cov.Conjugate[sig]],
   RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


(* ::Subsubsection::Closed:: *)
(*Roemer*)


RoemerNCombine = Compile[{{sig, _Complex, 1}, {sen, _Complex, 1}, {cov, _Complex, 2}}, (sig.cov.Conjugate[sen])/Sqrt[sen.cov.Conjugate[sen]],
   RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];

RoemerSCombine = Compile[{{sig, _Complex, 1}, {sen, _Complex, 1}, {cov, _Complex, 2}}, (sig.cov.Conjugate[sen])/(sen.cov.Conjugate[sen]),
   RuntimeOptions -> "Speed", RuntimeAttributes -> {Listable}];


(* ::Subsubsection::Closed:: *)
(*WSVD*)


WSVDCombine[sig_, cov_] := Block[{weight},
	weight = CovToWeight[cov];
	Map[WSVDCombineT[#, weight] &, sig, {-3}]
];

CovToWeight[cov_] := DiagonalMatrix[Sqrt[1./#[[1]]]].#[[2]] &[Eigensystem[cov]];

WSVDCombineT[sig_, weight_] := Block[{u, s, v, scale},
	{u, s, v} = SingularValueDecomposition[weight.sig];
	scale = Norm[#] Normalize[First@#] &[weight.u[[All, 1]]];
	Conjugate[v[[All, 1]]] s[[1, 1]] scale
];


WSVDCombine2[sig_, cov_] := Block[{weight, weighti},
	weight = CovToWeight2[cov]; weighti = Inverse[weight];
	Map[WSVDCombineT2[#, weight, weighti] &, sig, {-3}]
];

CovToWeight2[cov_] := Reverse /@ (Transpose[#[[2]]].DiagonalMatrix[1/Sqrt[#[[1]]]] &[Eigensystem[cov]]);

WSVDCombineT2[sig_, weight_, weighti_] := Block[{u, s, v, scale},
	{u, s, v} = SingularValueDecomposition[Transpose[sig].weight];
	scale = Norm[#] Normalize[First@#] &[Conjugate[v[[All, 1]]].weighti];
	u[[All, 1]] s[[1, 1]] scale
];


(* ::Subsubsection::Closed:: *)
(*MakeSense*)


SyntaxInformation[MakeSense] = {"ArgumentsPattern" -> {_, _}};

MakeSense[coils_, cov_] := DevideNoZero[#, CoilCombine[coils, cov, Method -> "RootSumSquares"]] & /@ coils


(* ::Subsubsection::Closed:: *)
(*NormalizeSpectra*)


SyntaxInformation[NormalizeSpectra] = {"ArgumentsPattern" -> {_}};

NormalizeSpectra[spec_] := 1000. Sign[Re@Mean[Flatten[spec]]] (spec/Max[Abs[spec]])


(* ::Subsection:: *)
(*HammingFilter*)


(* ::Subsubsection:: *)
(*MakeHammingFilter*)


SyntaxInformation[MakeHammingFilter]={"ArgumentsPattern"->{_}}

MakeHammingFilter[{zi_?IntegerQ, yi_?IntegerQ, xi_?IntegerQ}] := MakeHammingFilterI[Transpose[{-Floor[{xi, yi, zi}/2], Ceiling[{xi, yi, zi}/2] - 1}]];

MakeHammingFilter[{yi_?IntegerQ, xi_?IntegerQ}] := MakeHammingFilterI[Transpose[{-Floor[{xi, yi}/2], Ceiling[{xi, yi}/2] - 1}]];

MakeHammingFilter[{xi_?IntegerQ}] := MakeHammingFilter[xi];

MakeHammingFilter[xi_?IntegerQ] := MakeHammingFilterI[{-Floor[xi/2], Ceiling[xi/2] - 1}];


MakeHammingFilterI[{{xs_?IntegerQ, xe_?IntegerQ}, {ys_?IntegerQ, ye_?IntegerQ}, {zs_?IntegerQ, ze_?IntegerQ}}] := MakeHammingFilterI[{{xs,xe},{ys,ye},{zs,zs}}] = Block[{xm, ym, zm, hx, hy, hz},
	(*get ranges*)
	{xm, ym, zm} = Max[Abs[#]] & /@ {{xs, xe}, {ys, ye}, {zs, ze}};
	(*make filter*)
	Table[(0.54 + 0.46 Cos[(Pi x)/xm]) (0.54 + 0.46 Cos[(Pi y)/ym]) (0.54 + 0.46 Cos[(Pi z)/zm]), {z, zs, ze}, {y, ys, ye}, {x, xs, xe}]
]

MakeHammingFilterI[{{xs_?IntegerQ, xe_?IntegerQ}, {ys_?IntegerQ, ye_?IntegerQ}}] := MakeHammingFilterI[{{xs,xe},{ys,ye}}] = Block[{xm, ym, hx, hy},
	(*get ranges*)
	{xm, ym} = Max[Abs[#]] & /@ {{xs, xe}, {ys, ye}};
	(*make filter*)
	Table[(0.54 + 0.46 Cos[(Pi x)/xm]) (0.54 + 0.46 Cos[(Pi y)/ym]), {y, ys, ye}, {x, xs, xe}]
]

MakeHammingFilterI[{xs_?IntegerQ, xe_?IntegerQ}] := MakeHammingFilterI[{xs,xe}] = Block[{xm, hx},
	(*get ranges*)
	{xm} = Max[Abs[#]] & /@ {{xs, xe}};
	(*make filter*)
	Table[(0.54 + 0.46 Cos[(Pi x)/xm]), {x, xs, xe}]
]


(* ::Subsubsection:: *)
(*HammingFilterData*)


SyntaxInformation[HammingFilterData] = {"ArgumentsPattern"->{_}}

HammingFilterData[data_]:= FourierShifted[MakeHammingFilter[Dimensions[data]] InverseFourierShifted[data]]


(* ::Subsubsection:: *)
(*HammingFilterCSI*)


SyntaxInformation[HammingFilterCSI]={"ArgumentsPattern"->{_,_.}}

HammingFilterCSI[data_] := TransData[HammingFilterData/@TransData[data,"r"],"l"]


(* ::Subsubsection:: *)
(*DenoiseCSIdata*)


Options[DenoiseCSIdata] = {PCAKernel -> 5}

SyntaxInformation[DenoiseCSIdata]={"ArgumentsPattern"->{_, OptionsPattern[]}}

DenoiseCSIdata[spectra_, OptionsPattern[]] := Block[{stdMap, sig, out, hist, len, spectraDen},
	(* assusmes data is (x,y,z,spectra)*)
	len = Dimensions[spectra][[-1]];
	
	(*get the corner voxels to calcluate the noise standard deviation*)
	stdMap = Map[StandardDeviation, spectra, {-2}];
	sig = Mean[Flatten[stdMap[[{1, -1}, {1, -1}, {1, -1}]]]];
	stdMap=Flatten[stdMap];
	
	
	(*Plot the histogram of the noise standard deviations*)
	hist = SmoothHistogram[stdMap, PlotRange -> {Quantile[stdMap,{.05,.9}],Full}, 
    PlotStyle -> Thick, AxesStyle -> Directive[Thick, Black], 
    Ticks -> None, LabelStyle -> Directive[Thick, Black, Bold, 12], 
    PlotLabel -> "STD " <> ToString[Round[sig, .1]], ImageSize -> 100,
    GridLines -> {{sig}, None}];
    Print[hist];
    
    (*Denoise the spectra data with a 5x5x5 kernel*)
    {spectraDen, sig, out} = PCADeNoise[Transpose[Join[Re@#, Im@#]] &[TransData[spectra, "r"]],
    	1, sig, PCAClipping -> False, PCAKernel -> OptionValue[PCAKernel]];
    	
    TransData[Transpose[spectraDen][[1 ;; len]] + Transpose[spectraDen][[len + 1 ;;]] I, "l"]
]


(* ::Subsubsection:: *)
(*DeconvolveCSIdata*)


SyntaxInformation[DeconvolveCSIdata]={"ArgumentsPattern"->{_}}

DeconvolveCSIdata[spectra_] := Block[{dim, filt, spectraOut, ham},
	(*make tha hamming filter*)
	dim = Dimensions[spectra][[;; -2]];
	ham = MakeHammingFilter[dim];
	
	(*make the complex hamming filter point spread function and take the real part*)
	filt = Re@FourierShift[ShiftedInverseFourier[ArrayPad[ham, Transpose[{Floor[dim/2], Ceiling[dim/2]}]]]];
	filt = DevideNoZero[filt, Total[Flatten[filt]]];
	
	(*zero pad the spectra by factor two*)
	spectraOut = FourierRescaleData[TransData[spectra, "r"]];
	
	(*perform the deconvolution*)
	DistributeDefinitions[filt];
	spectraOut = ParallelMap[(
		Exp[Arg[#] I] ListDeconvolve[filt, Abs@#,
			Padding -> "Periodic", Method -> {"SteepestDescent", "Preconditioned" -> False}, MaxIterations -> 5]
		) &, spectraOut];
	
	(*rescale to original dimensions*)
	TransData[(RescaleData[Re@#, dim, InterpolationOrder -> 2] + RescaleData[Im@#, dim, InterpolationOrder -> 2] I) & /@ spectraOut, "l"]
]


(* ::Subsubsection:: *)
(*FourierRescaleData*)


SyntaxInformation[FourierRescaleData]={"ArgumentsPattern"->{_,_.}}

FourierRescaleData[data_, factor_ : 2] := Block[{dim, pad, scale},
	(*get the data dimensions*)
	dim = Switch[ArrayDepth[data],
		2, Dimensions[data],
		3, Dimensions[data],
		4, Dimensions[data][[2 ;;]]
	];
	
	If[factor >= 1,
		(*Upscale data*)
		pad = Transpose[{Floor[(factor - 1) (dim/2)],Ceiling[(factor - 1) (dim/2)]}];
		scale = factor^Length[pad];
		,
		(*Downscale data*)
		If[0 < factor < 1,
			pad = Transpose[{Floor[(factor - 1) (dim/2)], Ceiling[(factor - 1) (dim/2)]}];
			scale = factor^Length[pad];
		]
	];
	
	Switch[ArrayDepth[data],
		2, scale FourierShifted[ArrayPad[InverseFourierShifted[data], pad]],
		3, scale FourierShifted[ArrayPad[InverseFourierShifted[data], pad]],
		4, scale FourierShifted[ArrayPad[InverseFourierShifted[#], pad]] & /@ data
	]
]


(* ::Subsection:: *)
(*Recon Functions*)


(* ::Subsubsection:: *)
(*Coil weighted recon*)


Options[CoilWeightedRecon] = {DataShift -> 0, CoilSamples -> 2, Method -> "RoemerEqualSignal"};

CoilWeightedRecon[kspace_, noise_, head_, OptionsPattern[]] := Block[{shift, coilData, cov, sens, recon},
	shift = OptionValue[DataShift];
	
	(*make Image Data*)
	coilData = Map[FourierKspace2D[#, head] &, kspace, {-4}];
	cov = NoiseCovariance[noise];
	
	(*shift the echos to center if needed*)
	If[shift =!= 0,
		coilData = Table[If[EvenQ[i],
			RotateRight[coilData[[i]], {0, 0, 0, shift[[1]]}],
			RotateLeft[coilData[[i]], {0, 0, 0, shift[[2]]}]
		], {i, 1, Length[coilData]}]
	];
	
	(*make coil sensitivity*)
	sens = HammingFilterData /@ Switch[ArrayDepth[coilData], 4, coilData, 5, Mean@coilData[[{2, 3}]]];
	sens = MakeSense[sens, cov];
	(*perform the recon*)
	recon = Switch[ArrayDepth[coilData],
		4, CoilCombine[coilData, cov, sens, Method -> OptionValue[Method]],
		5, Transpose[CoilCombine[#, cov, sens, Method -> OptionValue[Method]] & /@ coilData]
	];
	
	(*scale to proper values*)
	recon = 1000. recon/Max[Abs[recon]];
	#[recon] & /@ {Abs, Arg, Re, Im}
]


(* ::Subsubsection:: *)
(*Coil weighted recon CSI*)

Options[CoilWeightedReconCSI] = {HammingFilter -> False, CoilSamples -> 5, Method -> "Roemer"};

CoilWeightedReconCSI[kspace_, noise_, head_, OptionsPattern[]] := Block[{fids, spectra, cov, coils, sosCoils, sens},
	
	spectra = Switch[ArrayDepth[kspace],
		4,(*no coil combination for 3D CSI*)
		fids = TransData[FourierKspaceCSI[kspace, head], "l"];
		TransData[Map[FourierShift[Fourier[#, FourierParameters -> {-1, 1}]] &, TransData[fids, "l"], {-2}], "r"];
		,
		5,(*perform spatial fourier for CSI*)
		fids = Transpose[FourierKspaceCSI[#, head] & /@ kspace];
		spectra = TransData[Map[FourierShift[Fourier[#, FourierParameters -> {-1, 1}]] &, TransData[fids, "l"], {-2}], "r"];
		
		(*noise correlation, inverse and withening matrix*)
		cov = NoiseCovariance[noise];
		Switch[OptionValue[Method],
			"Roemer",
			(*make coil sensitivity using the first 5 samples of the fid*)
			sens = MakeSense[HammingFilterCSI[Mean[fids[[1 ;; OptionValue[CoilSamples]]]]],cov];
			
			(*perform the recon*)
			TransData[CoilCombine[#, cov, sens, Method -> "RoemerEqualNoise"] & /@ spectra, "l"]
			,
			"WSVD",
			CoilCombine[spectra, cov, Method -> "WSVD"],
			"WSVD2",
			CoilCombine[spectra, cov, Method -> "WSVD2"]
		]
	];
	
	(*Normalize spectra*)
	spectra = NormalizeSpectra[spectra];
	If[OptionValue[HammingFilter], spectra = HammingFilterCSI[spectra]];
	
	spectra
]



(* ::Section:: *)
(*End Package*)


End[]

EndPackage[]