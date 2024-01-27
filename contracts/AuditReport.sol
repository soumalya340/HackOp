// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC1155/extensions/ERC1155Supply.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract AuditReport is Context, ERC1155Supply, ReentrancyGuard {
    uint256 private CounterProjectID;
    uint256 private CounterReportID;

    uint256 public thresoldPoint;

    address public immutable owner;

    struct Project {
        address ownerAddress;
        string projectURI;
        uint256 prizePool;
        bool isActive;
    }
    struct Report {
        uint256 projectId;
        address contributor;
        string reportURI;
        bool isVerified;
    }

    mapping(uint256 => Project) public projects;
    mapping(uint256 => Report) public reports;
    mapping(address => uint256) public leaderboard;

    event ProjectRegistered(
        uint256 projectId,
        address owner,
        uint256 prizePool
    );

    event ReportSubmitted(
        uint256 reportId,
        uint256 projectId,
        address contributor,
        string reportURI
    );

    event ReportVerified(uint256 reportId, uint256 reward);

    event NFTMinted(uint256 projecttId, address contributor);

    constructor(
        string memory baseURI,
        uint256 _thresoldPoint
    ) ERC1155(baseURI) {
        thresoldPoint = _thresoldPoint;
        owner = _msgSender();
    }

    function setThresoldPoints(uint256 point) external {
        thresoldPoint = point;
    }

    function registerProject(
        uint256 prizePool,
        string memory metadataURI
    ) external payable {
        require(prizePool <= msg.value, "AuditReport: Not enough funds!");
        CounterProjectID++;
        uint256 newProjectId = CounterProjectID;
        projects[newProjectId] = Project(
            _msgSender(),
            metadataURI,
            prizePool,
            true
        );
        emit ProjectRegistered(newProjectId, _msgSender(), prizePool);
    }

    function submitReport(
        uint256 projectId,
        string calldata reportURI,
        bytes memory data
    ) external {
        CounterReportID++;
        uint256 newReportId = CounterReportID;
        require(
            projects[projectId].isActive,
            "AuditReport: Project not active"
        );
        // We cannot just use balanceOf to create the new tokenId because tokens
        // can be burned (destroyed), so we need a separate counter.
        _mint(_msgSender(), projectId, 1, data);

        reports[newReportId] = Report(
            projectId,
            _msgSender(),
            reportURI,
            false
        );

        emit ReportSubmitted(newReportId, projectId, _msgSender(), reportURI);

        emit NFTMinted(projectId, _msgSender());
    }

    function verifyReport(
        uint256 reportId,
        uint256 reward
    ) external nonReentrant {
        Report storage report = reports[reportId];
        uint256 _projectId = report.projectId;

        Project storage project = projects[_projectId];

        require(
            project.ownerAddress == _msgSender() || owner == _msgSender(),
            "AuditReport: User is not authorized"
        );

        require(!report.isVerified, "AuditReport: Report already verified");

        require(
            project.prizePool >= reward,
            "AuditReport: Not enough to reward"
        );

        report.isVerified = true;

        project.prizePool -= reward;

        payable(report.contributor).transfer(reward);

        leaderboard[report.contributor] += 1;

        emit ReportVerified(reportId, reward);
    }

    /** Getter Functions **/

    /// @dev Returns the Uniform Resource Identifier (URI) for `tokenId` token.
    function uri(
        uint256 tokenId
    ) public view virtual override returns (string memory) {
        return projects[tokenId].projectURI;
    }

    function _beforeTokenTransfer(
        address operator,
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory amounts,
        bytes memory data
    ) internal virtual override(ERC1155Supply) {
        require(
            from == address(0) || to == address(0),
            "AuditReport : Asset cannot be transferred or destroyed!"
        );
        super._beforeTokenTransfer(operator, from, to, ids, amounts, data);
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(
        bytes4 interfaceId
    ) public view virtual override(ERC1155) returns (bool) {
        return super.supportsInterface(interfaceId);
    }
}
